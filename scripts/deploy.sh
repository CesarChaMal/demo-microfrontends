#!/bin/bash
# Deploys ONE microfrontend to AWS, to the place the live site loads it from.
#
# Usage (from the app's directory, after its build):
#   ../scripts/deploy.sh <app-name> <bundle-file>
#   e.g. ../scripts/deploy.sh layout-app single-spa-layout-app.umd.js
# Environment: S3_BUCKET and ORG_NAME (required), AWS_REGION (default eu-central-1).
#
# The site reads every app from the un-versioned prefix
#   s3://$S3_BUCKET/@$ORG_NAME/<app-name>/
# which the full deploy (./run.sh aws prod -> scripts/deploy-s3.sh) fills and
# which the import map (@$ORG_NAME/importmap.json) points at. This script syncs
# the app's dist/ to that same prefix, the way deploy-s3.sh does for each app,
# and leaves the import map alone.
#
# It used to upload to a per-commit prefix and repoint the import map through
# update-importmap.mjs. That never took effect: the helper was looked up in the
# app directory, node failed, the script carried on, re-uploaded the unchanged
# import map and printed "Deployment successful" while the site kept serving
# the old bundle. Hence the strict mode and the checks: a failed step fails the
# job, and nothing is uploaded unless the site will actually load it.
#
# Tests: bash scripts/deploy.test.sh
set -euo pipefail

APP_NAME=${1:-${APP_NAME:-}}
BUNDLE_FILE=${2:-${BUNDLE_FILE:-}}
# A third argument (shared dependencies as JSON) is accepted and ignored: only
# the full deploy writes the import map.
export AWS_REGION=${AWS_REGION:-eu-central-1}

fail() {
  echo "❌ $*" >&2
  exit 1
}

[ -n "$APP_NAME" ] && [ -n "$BUNDLE_FILE" ] ||
  fail "Usage: deploy.sh <app-name> <bundle-file>   e.g. deploy.sh layout-app single-spa-layout-app.umd.js"
[ -n "${S3_BUCKET:-}" ] || fail "S3_BUCKET is not set"
[ -n "${ORG_NAME:-}" ] || fail "ORG_NAME is not set"

# The sync below deletes whatever else sits under its target, so the target
# must be exactly @<org>/<app>/: no empty part, no slash, no dot segment.
[[ "$S3_BUCKET" =~ ^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$ ]] || fail "Invalid S3_BUCKET"
[[ "$ORG_NAME" =~ ^[A-Za-z0-9]+([_-][A-Za-z0-9]+)*$ ]] || fail "Invalid ORG_NAME"
[[ "$APP_NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "Invalid app name '$APP_NAME'"
[[ "$BUNDLE_FILE" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*\.js$ ]] || fail "Invalid bundle file '$BUNDLE_FILE'"
[ -f "dist/$BUNDLE_FILE" ] ||
  fail "dist/$BUNDLE_FILE not found. Build the app first, and pass the bundle name the build really writes."

MODULE="@${ORG_NAME}/${APP_NAME}"
PREFIX="@${ORG_NAME}/${APP_NAME}"

echo "🔍 Checking the bucket..."
aws s3api head-bucket --bucket "$S3_BUCKET" ||
  fail "The bucket is not reachable. The full deploy (./run.sh aws prod) creates and configures it."

echo "🔍 Checking that the site loads $MODULE from this deploy's target..."
IMPORT_MAP=$(mktemp)
trap 'rm -f "$IMPORT_MAP"' EXIT
aws s3 cp "s3://$S3_BUCKET/@${ORG_NAME}/importmap.json" "$IMPORT_MAP" >/dev/null ||
  fail "No import map in the bucket. Run the full deploy (./run.sh aws prod) once."
# Prints the URL the import map loads the module from; that URL (on whatever
# host the site is served through) is what the last line reports as live.
LIVE_URL=$(MODULE="$MODULE" EXPECTED_PATH="/${PREFIX}/${BUNDLE_FILE}" node -e '
  const map = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
  const { MODULE, EXPECTED_PATH } = process.env;
  const url = map.imports && map.imports[MODULE];
  if (!url) {
    console.error(`The import map has no entry for ${MODULE}.`);
    process.exit(1);
  }
  let path;
  try {
    path = decodeURIComponent(new URL(url).pathname);
  } catch (err) {
    console.error(`The import map entry for ${MODULE} is not a URL: ${url}`);
    process.exit(1);
  }
  if (path !== EXPECTED_PATH) {
    console.error(`The import map loads ${MODULE} from ${url}, not from ${EXPECTED_PATH}.`);
    process.exit(1);
  }
  console.log(url);
' "$IMPORT_MAP") ||
  fail "The site would not load what this deploy uploads. Fix the bundle name passed to deploy.sh, or rebuild the import map with the full deploy (./run.sh aws prod)."

echo "📤 Uploading dist/ to s3://$S3_BUCKET/$PREFIX/ ..."
aws s3 sync dist/ "s3://$S3_BUCKET/$PREFIX/" --delete

echo "🔍 Checking the uploaded bundle..."
LOCAL_SIZE=$(wc -c < "dist/$BUNDLE_FILE" | tr -d ' ')
REMOTE_SIZE=$(aws s3api head-object --bucket "$S3_BUCKET" --key "$PREFIX/$BUNDLE_FILE" --query ContentLength --output text) ||
  fail "Could not read the uploaded bundle back from the bucket."
[ "$LOCAL_SIZE" = "$REMOTE_SIZE" ] ||
  fail "The bundle in the bucket is $REMOTE_SIZE bytes, the local build is $LOCAL_SIZE bytes."

echo "✅ $MODULE is live at $LIVE_URL"
