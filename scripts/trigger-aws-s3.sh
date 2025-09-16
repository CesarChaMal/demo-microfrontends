#!/bin/bash

# Advanced AWS S3 Deployment Script
# Parallel deployment with CloudFront invalidation and optimization

set -e

echo "🚀 Starting advanced AWS S3 deployment..."

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

# Check prerequisites
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

if [ -z "$S3_BUCKET" ]; then
    echo "❌ S3_BUCKET not set in .env file"
    exit 1
fi

if [ -z "$AWS_REGION" ]; then
    echo "❌ AWS_REGION not set in .env file"
    exit 1
fi

if [ -z "$ORG_NAME" ]; then
    echo "❌ ORG_NAME not set in .env file"
    exit 1
fi

echo "📋 Configuration:"
echo "   S3 Bucket: $S3_BUCKET"
echo "   AWS Region: $AWS_REGION"
echo "   Organization: $ORG_NAME"

# Switch to AWS mode and build
echo "🔄 Switching to AWS mode..."
npm run mode:aws

echo "🔨 Building all applications for production..."
npm run build:prod

echo "🔨 Building root application for AWS..."
npm run build:root:aws:prod

# Deploy to S3 with parallel execution
echo "📤 Deploying to S3 with parallel execution..."
npm run deploy:s3:prod

# CloudFront invalidation (if distribution exists)
if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo "🔄 Invalidating CloudFront cache..."
    aws cloudfront create-invalidation \
        --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
        --paths "/*" \
        --region $AWS_REGION || echo "⚠️  CloudFront invalidation failed (continuing...)"
else
    echo "📝 No CloudFront distribution configured (skipping invalidation)"
fi

# Display results
S3_WEBSITE_URL="http://$S3_BUCKET.s3-website,$AWS_REGION.amazonaws.com"
echo ""
echo "✅ Advanced AWS S3 deployment completed!"
echo "🌍 Website URL: $S3_WEBSITE_URL"
echo "🔗 Import Map: https://$S3_BUCKET.s3.$AWS_REGION.amazonaws.com/@$ORG_NAME/importmap.json"
echo ""
echo "🎯 All 12 microfrontends deployed with optimization:"
echo "   - Parallel execution for faster deployment"
echo "   - CloudFront invalidation (if configured)"
echo "   - Production-ready with CDN integration"