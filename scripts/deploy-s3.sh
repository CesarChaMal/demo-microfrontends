#!/bin/bash

# Deploy Microfrontends to S3
# Usage: ./deploy-s3.sh [environment]
# Environment: dev (default), prod

set -euo pipefail

# Load environment variables
if [ -f ".env" ]; then
    echo "📄 Loading environment variables from .env..."
    export $(grep -v '^#' ".env" | xargs)
fi

ENV=${1:-dev}
BUCKET_NAME=${S3_BUCKET}
REGION=${AWS_REGION:-eu-central-1}

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: S3_BUCKET not set in .env"
    exit 1
fi

echo "🚀 Deploying to S3 bucket: $BUCKET_NAME ($ENV environment)"

# Check if S3 bucket exists, create if not
echo "🔍 Checking if S3 bucket exists..."
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "📦 Creating S3 bucket $BUCKET_NAME..."
    if [ "$REGION" = "us-east-1" ]; then
        aws s3 mb "s3://$BUCKET_NAME"
    else
        aws s3 mb "s3://$BUCKET_NAME" --region "$REGION"
    fi
    
    echo "🌐 Enabling static website hosting..."
    aws s3 website "s3://$BUCKET_NAME" --index-document index.html --error-document error.html
    
    echo "🔓 Removing public access block..."
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
    
    echo "📋 Adding public read policy..."
    aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::'"$BUCKET_NAME"'/*"
            }
        ]
    }'
    
    echo "🔧 Setting up CORS configuration..."
    aws s3api put-bucket-cors --bucket "$BUCKET_NAME" --cors-configuration '{
        "CORSRules": [
            {
                "AllowedHeaders": ["*"],
                "AllowedMethods": ["GET", "HEAD", "PUT", "POST"],
                "AllowedOrigins": ["*"],
                "ExposeHeaders": ["ETag"],
                "MaxAgeSeconds": 3000
            }
        ]
    }'
    
    echo "✅ S3 bucket setup complete!"
else
    echo "✅ S3 bucket $BUCKET_NAME already exists"
fi

# Build all applications
echo "🔨 Building all applications for $ENV..."
if [ "$ENV" = "prod" ]; then
    npm run build:prod
else
    npm run build:dev
fi

# Build root application
echo "🔨 Building root application..."
cd single-spa-root
npm run build
cd ..

# Deploy root application to S3
echo "📤 Deploying root application to S3..."
aws s3 sync single-spa-root/dist/ s3://$BUCKET_NAME/ --delete

# Deploy each microfrontend
echo "📤 Deploying microfrontends to S3..."

# Create import map
echo "📋 Creating import map..."
cat > importmap.json << EOF
{
  "imports": {
    "@${ORG_NAME}/auth-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/auth-app/single-spa-auth-app.umd.js",
    "@${ORG_NAME}/layout-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/layout-app/single-spa-layout-app.umd.js",
    "@${ORG_NAME}/home-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/home-app/single-spa-home-app.js",
    "@${ORG_NAME}/angular-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/angular-app/single-spa-angular-app.js",
    "@${ORG_NAME}/vue-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/vue-app/single-spa-vue-app.umd.js",
    "@${ORG_NAME}/react-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/react-app/single-spa-react-app.js",
    "@${ORG_NAME}/vanilla-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/vanilla-app/single-spa-vanilla-app.js",
    "@${ORG_NAME}/webcomponents-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/webcomponents-app/single-spa-webcomponents-app.js",
    "@${ORG_NAME}/typescript-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/typescript-app/single-spa-typescript-app.js",
    "@${ORG_NAME}/jquery-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/jquery-app/single-spa-jquery-app.js",
    "@${ORG_NAME}/svelte-app": "https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/svelte-app/single-spa-svelte-app.js"
  }
}
EOF

# Upload import map
aws s3 cp importmap.json s3://$BUCKET_NAME/@${ORG_NAME}/importmap.json
rm importmap.json

# Upload each microfrontend
APPS=("auth" "layout" "home" "angular" "vue" "react" "vanilla" "webcomponents" "typescript" "jquery" "svelte")

for app in "${APPS[@]}"; do
    app_dir="single-spa-${app}-app"
    if [ -d "$app_dir/dist" ]; then
        echo "📤 Uploading $app app..."
        aws s3 sync "$app_dir/dist/" "s3://$BUCKET_NAME/@${ORG_NAME}/${app}-app/" --delete
    else
        echo "⚠️  Warning: $app_dir/dist not found, skipping..."
    fi
done

echo ""
echo "🎉 Deployment complete!"
echo "📍 Bucket: $BUCKET_NAME"
echo "🌍 Website URL: ${S3_WEBSITE_URL}"
echo "📦 Import Map: https://${BUCKET_NAME}.s3.${REGION}.amazonaws.com/@${ORG_NAME}/importmap.json"
echo ""
echo "✅ Your microfrontend application is now live!"