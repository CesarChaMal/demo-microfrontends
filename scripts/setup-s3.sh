#!/bin/bash

# S3 Setup Script for Single-SPA Microfrontends
# 
# Usage Examples:
#   Action-only (uses default bucket from .env):
#     ./setup-s3.sh public           # Full public setup with default bucket
#     ./setup-s3.sh cors             # CORS setup with default bucket  
#     ./setup-s3.sh s3               # Basic bucket with default name
#     ./setup-s3.sh                  # Same as above (s3 is default)
#
#   Traditional bucket + action:
#     ./setup-s3.sh my-bucket public # Full public setup with custom bucket
#     ./setup-s3.sh my-bucket cors   # CORS setup with custom bucket
#     ./setup-s3.sh my-bucket        # Basic bucket with custom name
#
# Actions:
#   s3     - Creates basic S3 bucket only (default)
#   cors   - Creates S3 bucket + CORS for microfrontends
#   public - Full setup: bucket + website hosting + public policy + CORS
#
# How it works:
#   The script detects if the first argument is an action (s3, cors, or public) 
#   and no second argument exists, then uses the default bucket from .env.
#
# Environment:
#   Loads S3_BUCKET, AWS_REGION from .env in current folder

set -euo pipefail

# Load environment variables from current folder
load_env() {
    if [ -f ".env" ]; then
        echo "📄 Loading environment variables from .env..."
        export $(grep -v '^#' ".env" | xargs)
    fi
}

load_env

# Parse arguments - handle action-only usage
if [[ "$1" =~ ^(s3|cors|public)$ ]] && [ -z "${2:-}" ]; then
    # First argument is an action, use default bucket
    BUCKET_NAME=${S3_BUCKET}
    ACTION=$1
else
    # Standard usage: bucket-name [action]
    BUCKET_NAME=${1:-$S3_BUCKET}
    ACTION=${2:-s3}
fi
REGION=${AWS_REGION:-eu-central-1}

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: No bucket name provided and S3_BUCKET not set in .env"
    echo "Usage: ./setup-s3.sh [bucket-name] [action]"
    echo "Actions: s3 (default), cors, public"
    exit 1
fi

echo "🚀 S3 Setup: $ACTION for bucket $BUCKET_NAME in region $REGION"

# Function definitions
create_bucket() {
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        echo "✅ Bucket $BUCKET_NAME already exists"
        return 0
    fi
    
    echo "📦 Creating bucket $BUCKET_NAME..."
    if [ "$REGION" = "us-east-1" ]; then
        aws s3 mb s3://$BUCKET_NAME
    else
        aws s3 mb s3://$BUCKET_NAME --region $REGION
    fi
    echo "✅ Bucket created successfully"
}

setup_website() {
    echo "🌐 Enabling static website hosting..."
    aws s3 website s3://$BUCKET_NAME --index-document index.html --error-document error.html
    
    echo "🔓 Removing public access block..."
    aws s3api put-public-access-block \
        --bucket $BUCKET_NAME \
        --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
}

setup_policy() {
    echo "📋 Adding public read policy..."
    aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*"
            }
        ]
    }'
}

setup_cors() {
    echo "🔧 Configuring CORS for microfrontends..."
    aws s3api put-bucket-cors --bucket $BUCKET_NAME --cors-configuration '{
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
}

show_results() {
    echo ""
    echo "🎉 S3 configuration complete!"
    echo "📍 Bucket: $BUCKET_NAME"
    echo "🌍 Region: $REGION"
    echo "🔗 Website URL: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
    echo "📦 S3 URL: https://$BUCKET_NAME.s3.$REGION.amazonaws.com"
    echo "✅ Ready for microfrontend deployment!"
}

# Execute based on action
case $ACTION in
    "s3")
        create_bucket
        echo "✅ Basic S3 bucket ready!"
        ;;
    "cors")
        create_bucket
        setup_cors
        echo "✅ S3 bucket with CORS configured!"
        ;;
    "public")
        create_bucket
        setup_website
        setup_policy
        setup_cors
        show_results
        ;;
    *)
        echo "❌ Invalid action: $ACTION"
        echo "Available actions: s3 (basic bucket), cors (bucket + CORS), public (full public setup)"
        exit 1
        ;;
esac