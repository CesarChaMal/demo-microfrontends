#!/bin/bash
# Tests for scripts/deploy.sh (the per-app AWS deploy), run against a stub
# `aws` so nothing touches a real bucket:
#   bash scripts/deploy.test.sh
# The stub records every call and keeps "uploaded" files in a temp folder, so
# each case can assert where the script wrote and whether it stopped.
set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/deploy.sh"
WORK=$(mktemp -d) || exit 1
trap 'rm -rf "$WORK"' EXIT
PASS=0
FAIL=0

mkdir -p "$WORK/bin"
cat > "$WORK/bin/aws" <<'STUB'
#!/bin/bash
# Stub aws CLI. State lives in $FAKE_S3 (one folder per bucket); calls are
# appended to $AWS_LOG. FAKE_FAIL names a command ("s3 sync", "s3api head-bucket",
# ...) that must fail.
echo "$*" >> "$AWS_LOG"
echo "${AWS_REGION:-unset}" > "$AWS_LOG.region"
cmd="$1 $2"
if [ "${FAKE_FAIL:-}" = "$cmd" ]; then echo "stub: forced failure of $cmd" >&2; exit 1; fi
path_of() { echo "$FAKE_S3/${1#s3://}"; }
case "$cmd" in
  "s3api head-bucket")
    [ -d "$FAKE_S3/$4" ] || { echo "stub: no such bucket" >&2; exit 254; } ;;
  "s3 ls")
    [ -d "$(path_of "$3")" ] || { echo "An error occurred (NoSuchBucket)" >&2; exit 254; } ;;
  "s3 cp")
    if [[ "$3" == s3://* ]]; then
      src=$(path_of "$3"); [ -f "$src" ] || { echo "stub: 404 $3" >&2; exit 1; }
      cp "$src" "$4"
    else
      dst=$(path_of "$4"); mkdir -p "$(dirname "$dst")"; cp "$3" "$dst"
    fi ;;
  "s3 sync")
    dst=$(path_of "$4"); dst=${dst%/}
    case " $* " in *" --delete "*) rm -rf "$dst" ;; esac
    mkdir -p "$dst"; cp -r "$3". "$dst/"
    [ -z "${FAKE_SYNC_PARTIAL:-}" ] || { echo "stub: one transfer failed" >&2; exit 1; } ;;
  "s3api head-object")
    # aws s3api head-object --bucket B --key K --query ContentLength --output text
    f="$FAKE_S3/$4/$6"; [ -f "$f" ] || { echo "stub: 404 $6" >&2; exit 254; }
    if [ -n "${FAKE_REMOTE_SIZE:-}" ]; then echo "$FAKE_REMOTE_SIZE"; else wc -c < "$f" | tr -d ' '; fi ;;
  *) echo "stub: unexpected aws call: $*" >&2; exit 2 ;;
esac
STUB
chmod +x "$WORK/bin/aws"

BUCKET=demo-bucket
ORG=acme
URL_BASE="https://$BUCKET.s3.eu-central-1.amazonaws.com/@$ORG"

# A fresh app folder + bucket for one case. $1 = the import-map URL for layout-app
# ("" = no entry, "none" = no import map file at all).
setup() {
  rm -rf "$WORK/app" "$WORK/s3" "$WORK/aws.log"
  mkdir -p "$WORK/app/dist/img" "$WORK/s3/$BUCKET/@$ORG/layout-app/old-version" "$WORK/s3/$BUCKET/@$ORG/vue-app"
  echo "console.log('new layout build')" > "$WORK/app/dist/single-spa-layout-app.umd.js"
  echo "map" > "$WORK/app/dist/single-spa-layout-app.umd.js.map"
  echo "svg" > "$WORK/app/dist/img/logo.svg"
  echo "old" > "$WORK/s3/$BUCKET/@$ORG/layout-app/single-spa-layout-app.umd.js"
  echo "stale" > "$WORK/s3/$BUCKET/@$ORG/layout-app/old-version/single-spa-layout-app.umd.js"
  echo "vue" > "$WORK/s3/$BUCKET/@$ORG/vue-app/single-spa-vue-app.umd.js"
  echo "<html>root</html>" > "$WORK/s3/$BUCKET/index.html"
  case "$1" in
    none) ;;
    "") echo "{\"imports\":{\"@$ORG/vue-app\":\"$URL_BASE/vue-app/single-spa-vue-app.umd.js\"}}" > "$WORK/s3/$BUCKET/@$ORG/importmap.json" ;;
    *) echo "{\"imports\":{\"@$ORG/layout-app\":\"$1\",\"@$ORG/vue-app\":\"$URL_BASE/vue-app/single-spa-vue-app.umd.js\"}}" > "$WORK/s3/$BUCKET/@$ORG/importmap.json" ;;
  esac
  : > "$WORK/aws.log"
}

# run <env assignments...> -- <deploy.sh args...>   -> sets RC and OUT
run() {
  local envs=()
  while [ "$1" != "--" ]; do envs+=("$1"); shift; done
  shift
  OUT=$(cd "$WORK/app" && env -i PATH="$WORK/bin:$PATH" HOME="$WORK" AWS_LOG="$WORK/aws.log" FAKE_S3="$WORK/s3" \
    "${envs[@]}" bash "$SCRIPT" "$@" 2>&1)
  RC=$?
}

check() { # check "<what>" <condition...>
  local what=$1; shift
  if "$@"; then PASS=$((PASS + 1)); else FAIL=$((FAIL + 1)); echo "  FAIL: $what"; echo "$OUT" | sed 's/^/    | /' | tail -8; fi
}
live() { cat "$WORK/s3/$BUCKET/@$ORG/layout-app/single-spa-layout-app.umd.js" 2>/dev/null; }
bucket_untouched() { [ "$(live)" = "old" ] && [ -f "$WORK/s3/$BUCKET/index.html" ] && [ -f "$WORK/s3/$BUCKET/@$ORG/vue-app/single-spa-vue-app.umd.js" ]; }
no_sync() { ! grep -q "^s3 sync" "$WORK/aws.log"; }
GOOD_URL="$URL_BASE/layout-app/single-spa-layout-app.umd.js"
ENVS=(S3_BUCKET=$BUCKET ORG_NAME=$ORG AWS_REGION=eu-central-1)

echo "1. a good deploy replaces the bundle the site loads"
setup "$GOOD_URL"; run "${ENVS[@]}" -- layout-app single-spa-layout-app.umd.js
check "exits 0" [ "$RC" -eq 0 ]
check "says it is live" grep -q "is live at" <<<"$OUT"
check "the live bundle is the new build" [ "$(live)" = "console.log('new layout build')" ]
check "assets land under the app prefix" [ -f "$WORK/s3/$BUCKET/@$ORG/layout-app/img/logo.svg" ]
check "leftovers under the app prefix are removed" [ ! -e "$WORK/s3/$BUCKET/@$ORG/layout-app/old-version" ]
check "the sync targets exactly the app prefix" grep -qx "s3 sync dist/ s3://$BUCKET/@$ORG/layout-app/ --delete" "$WORK/aws.log"
check "the root and the other apps are untouched" [ -f "$WORK/s3/$BUCKET/index.html" -a -f "$WORK/s3/$BUCKET/@$ORG/vue-app/single-spa-vue-app.umd.js" ]
check "the import map is not rewritten" [ "$(grep -c "importmap.json s3://" "$WORK/aws.log")" -eq 0 ]

echo "2. an old third argument (shared dependencies) is still accepted"
setup "$GOOD_URL"; run "${ENVS[@]}" -- layout-app single-spa-layout-app.umd.js '{"vue":"https://cdn.example/vue.js"}'
check "exits 0" [ "$RC" -eq 0 ]

echo "3. a failed upload fails the job"
setup "$GOOD_URL"; run "${ENVS[@]}" "FAKE_FAIL=s3 sync" -- layout-app single-spa-layout-app.umd.js
check "exits non-zero" [ "$RC" -ne 0 ]
check "does not claim success" bash -c '! grep -qE "is live at" <<<"$1"' _ "$OUT"
setup "$GOOD_URL"; run "${ENVS[@]}" FAKE_SYNC_PARTIAL=1 -- layout-app single-spa-layout-app.umd.js
check "partial upload failure: exits non-zero" [ "$RC" -ne 0 ]
check "partial upload failure: does not claim success" bash -c '! grep -qE "is live at" <<<"$1"' _ "$OUT"

echo "4. an unreachable bucket fails the job before anything is written"
setup "$GOOD_URL"; run "${ENVS[@]}" "FAKE_FAIL=s3api head-bucket" -- layout-app single-spa-layout-app.umd.js
check "exits non-zero" [ "$RC" -ne 0 ]
check "nothing synced" no_sync
check "bucket untouched" bucket_untouched

echo "5. no import map: fail, do not upload where nothing points"
setup none; run "${ENVS[@]}" -- layout-app single-spa-layout-app.umd.js
check "exits non-zero" [ "$RC" -ne 0 ]
check "nothing synced" no_sync

echo "6. the import map has no entry for this app"
setup ""; run "${ENVS[@]}" -- layout-app single-spa-layout-app.umd.js
check "exits non-zero" [ "$RC" -ne 0 ]
check "nothing synced" no_sync

echo "7. the import map loads the app from somewhere else"
setup "$URL_BASE/layout-app/abc123/single-spa-layout-app.umd.js"; run "${ENVS[@]}" -- layout-app single-spa-layout-app.umd.js
check "exits non-zero" [ "$RC" -ne 0 ]
check "nothing synced" no_sync
setup "$URL_BASE/layout-app/main.js"; run "${ENVS[@]}" -- layout-app single-spa-layout-app.umd.js
check "another bundle name: exits non-zero" [ "$RC" -ne 0 ]
check "another bundle name: nothing synced" no_sync

echo "8. the bundle was not built"
setup "$GOOD_URL"; rm "$WORK/app/dist/single-spa-layout-app.umd.js"; run "${ENVS[@]}" -- layout-app single-spa-layout-app.umd.js
check "exits non-zero" [ "$RC" -ne 0 ]
check "nothing synced" no_sync
check "bucket untouched" bucket_untouched

echo "9. missing or unsafe settings never reach the sync (it deletes under its target)"
for case in "S3_BUCKET= ORG_NAME=$ORG|layout-app" "S3_BUCKET=$BUCKET ORG_NAME=|layout-app" "S3_BUCKET=$BUCKET ORG_NAME=$ORG|" \
            "S3_BUCKET=$BUCKET ORG_NAME=$ORG|../vue-app" "S3_BUCKET=$BUCKET ORG_NAME=$ORG|layout-app/.." "S3_BUCKET=$BUCKET ORG_NAME=../x|layout-app" \
            "S3_BUCKET=$BUCKET ORG_NAME=$ORG|." "S3_BUCKET=$BUCKET ORG_NAME=a/b|layout-app"; do
  setup "$GOOD_URL"
  IFS='|' read -r envpart app <<<"$case"
  # shellcheck disable=SC2086
  run $envpart AWS_REGION=eu-central-1 -- "$app" single-spa-layout-app.umd.js
  check "[$case] exits non-zero" [ "$RC" -ne 0 ]
  check "[$case] nothing synced" no_sync
  check "[$case] bucket untouched" bucket_untouched
  check "[$case] stopped before any aws call" [ ! -s "$WORK/aws.log" ]
done
for bad in "Bad_Bucket" "a/b" "-x"; do
  setup "$GOOD_URL"; run S3_BUCKET="$bad" ORG_NAME=$ORG AWS_REGION=eu-central-1 -- layout-app single-spa-layout-app.umd.js
  check "[bucket $bad] rejected before any aws call" [ "$RC" -ne 0 -a ! -s "$WORK/aws.log" ]
done
setup "$GOOD_URL"; mkdir -p "$WORK/app/dist/sub"; echo x > "$WORK/app/dist/sub/x.js"; run "${ENVS[@]}" -- layout-app sub/x.js
check "bundle in a subfolder: rejected by name" grep -q "Invalid bundle file" <<<"$OUT"
setup "$GOOD_URL"; run "${ENVS[@]}" -- layout-app
check "no bundle argument: exits non-zero" [ "$RC" -ne 0 ]
check "no bundle argument: nothing synced" no_sync
setup "$GOOD_URL"; run "${ENVS[@]}" -- layout-app ../../etc/passwd
check "bundle path with slashes: exits non-zero" [ "$RC" -ne 0 ]
check "bundle path with slashes: nothing synced" no_sync

echo "10. the uploaded bundle is checked against the local build"
setup "$GOOD_URL"; run "${ENVS[@]}" FAKE_REMOTE_SIZE=1 -- layout-app single-spa-layout-app.umd.js
check "size mismatch: exits non-zero" [ "$RC" -ne 0 ]
setup "$GOOD_URL"; run "${ENVS[@]}" "FAKE_FAIL=s3api head-object" -- layout-app single-spa-layout-app.umd.js
check "unverifiable upload: exits non-zero" [ "$RC" -ne 0 ]

echo "11. AWS_REGION defaults to eu-central-1"
setup "$GOOD_URL"; run S3_BUCKET=$BUCKET ORG_NAME=$ORG -- layout-app single-spa-layout-app.umd.js
check "exits 0 without AWS_REGION" [ "$RC" -eq 0 ]
check "the aws CLI sees the default region" [ "$(cat "$WORK/aws.log.region" 2>/dev/null)" = "eu-central-1" ]

echo "12. the import map may point at another host (a CDN in front of the bucket)"
CDN_URL="https://d111111abcdef8.cloudfront.net/@$ORG/layout-app/single-spa-layout-app.umd.js"
setup "$CDN_URL"; run "${ENVS[@]}" -- layout-app single-spa-layout-app.umd.js
check "exits 0" [ "$RC" -eq 0 ]
check "the live bundle is the new build" [ "$(live)" = "console.log('new layout build')" ]
check "reports the URL the site really loads" grep -qF "is live at $CDN_URL" <<<"$OUT"

echo
echo "passed: $PASS, failed: $FAIL"
[ "$FAIL" -eq 0 ]
