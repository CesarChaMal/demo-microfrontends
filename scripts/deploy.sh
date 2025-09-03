#!/bin/bash

# Dynamic deployment script for all microfrontends
# Usage: ./deploy.sh <app-name> <bundle-file> [shared-deps-json]

APP_NAME=${1:-$APP_NAME}
BUNDLE_FILE=${2:-$BUNDLE_FILE}
SHARED_DEPS=${3:-$SHARED_DEPS}

if [ -z "$APP_NAME" ] || [ -z "$BUNDLE_FILE" ]; then
    echo "Error: APP_NAME and BUNDLE_FILE are required"
    echo "Usage: ./deploy.sh <app-name> <bundle-file> [shared-deps-json]"
    echo "Or set APP_NAME and BUNDLE_FILE environment variables"
    exit 1
fi

echo "Deploying $APP_NAME with bundle $BUNDLE_FILE..."

# Check if S3 bucket exists, create if not
echo "Checking if S3 bucket exists..."
if ! aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "S3 bucket $S3_BUCKET exists"
else
    echo "Creating S3 bucket $S3_BUCKET..."
    aws s3 mb "s3://$S3_BUCKET" --region "$AWS_REGION"
    aws s3 website "s3://$S3_BUCKET" --index-document index.html --error-document error.html
    
    # Setup CORS configuration
    echo "Setting up CORS configuration..."
    cat > cors-config.json << EOF
{
    "CORSRules": [
        {
            "AllowedHeaders": ["*"],
            "AllowedMethods": ["GET", "HEAD"],
            "AllowedOrigins": ["*"],
            "ExposeHeaders": [],
            "MaxAgeSeconds": 3000
        }
    ]
}
EOF
    aws s3api put-bucket-cors --bucket "$S3_BUCKET" --cors-configuration file://cors-config.json --region "$AWS_REGION"
    rm cors-config.json
    echo "CORS configuration applied"
fi

# Deploy built files to S3 with commit SHA
echo "Deploying to S3..."
mkdir -p "dist/@${ORG_NAME}/${APP_NAME}/${GITHUB_SHA}"
mv dist/*.* "dist/@${ORG_NAME}/${APP_NAME}/${GITHUB_SHA}/"
aws s3 sync dist/ "s3://$S3_BUCKET/" --cache-control 'max-age=31536000'

echo "Downloading import map from S3"
aws s3 cp "s3://$S3_BUCKET/@${ORG_NAME}/importmap.json" importmap.json || echo '{}' > importmap.json

echo "Updating import map to point to new version of @${ORG_NAME}/${APP_NAME}"
export TRAVIS_COMMIT=$GITHUB_SHA
export APP_NAME
export BUNDLE_FILE
export SHARED_DEPS
node ../scripts/update-importmap.mjs

echo "Uploading new import map to S3"
aws s3 cp importmap.json "s3://$S3_BUCKET/@${ORG_NAME}/importmap.json" --cache-control 'public, must-revalidate, max-age=0'
echo "Deployment successful"