#!/bin/bash

# CloudFront CDN Status Checker
# Checks CloudFront distribution status, origin health, and S3 bucket contents

set -euo pipefail

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

DISTRIBUTION_ID=${CLOUDFRONT_DISTRIBUTION_ID:-}
BUCKET_NAME=${S3_BUCKET:-}

if [ -z "$DISTRIBUTION_ID" ]; then
    echo "❌ CLOUDFRONT_DISTRIBUTION_ID not set in .env"
    exit 1
fi

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ S3_BUCKET not set in .env"
    exit 1
fi

echo "🔍 CloudFront CDN Status Check"
echo "================================"

# 1. Check CloudFront distribution status
echo "📡 CloudFront Distribution Status:"
STATUS=$(aws cloudfront get-distribution --id "$DISTRIBUTION_ID" --query "Distribution.Status" --output text)
echo "   Status: $STATUS"

# 2. Get CloudFront domain
CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution --id "$DISTRIBUTION_ID" --query "Distribution.DomainName" --output text)
echo "   Domain: https://$CLOUDFRONT_DOMAIN"

# 3. Check origin configuration
echo ""
echo "🎯 Origin Configuration:"
ORIGIN_DOMAIN=$(aws cloudfront get-distribution --id "$DISTRIBUTION_ID" --query "Distribution.DistributionConfig.Origins.Items[0].DomainName" --output text)
echo "   Origin: $ORIGIN_DOMAIN"

# 4. Check S3 bucket website configuration
echo ""
echo "🪣 S3 Bucket Status:"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "   ✅ Bucket exists: $BUCKET_NAME"
    
    # Check website configuration
    if aws s3api get-bucket-website --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
        echo "   ✅ Website hosting enabled"
        INDEX_DOC=$(aws s3api get-bucket-website --bucket "$BUCKET_NAME" --query "IndexDocument.Suffix" --output text)
        echo "   📄 Index document: $INDEX_DOC"
    else
        echo "   ❌ Website hosting not configured"
    fi
    
    # Check if index.html exists
    if aws s3api head-object --bucket "$BUCKET_NAME" --key "index.html" >/dev/null 2>&1; then
        echo "   ✅ index.html exists"
    else
        echo "   ❌ index.html missing"
    fi
    
    # Count total files
    FILE_COUNT=$(aws s3 ls s3://$BUCKET_NAME/ --recursive | wc -l)
    echo "   📊 Total files: $FILE_COUNT"
    
else
    echo "   ❌ Bucket does not exist: $BUCKET_NAME"
fi

# 5. Test S3 website endpoint
echo ""
echo "🌐 S3 Website Endpoint Test:"
S3_WEBSITE_URL="http://$BUCKET_NAME.s3-website.${AWS_REGION:-eu-central-1}.amazonaws.com"
echo "   Testing: $S3_WEBSITE_URL"

if curl -s -I "$S3_WEBSITE_URL" | head -1 | grep -q "200\|301\|302"; then
    echo "   ✅ S3 website endpoint accessible"
else
    echo "   ❌ S3 website endpoint not accessible"
    echo "   💡 Run: npm run s3:setup:public"
fi

# 6. Test CloudFront endpoint
echo ""
echo "☁️ CloudFront Endpoint Test:"
CLOUDFRONT_URL="https://$CLOUDFRONT_DOMAIN"
echo "   Testing: $CLOUDFRONT_URL"

if curl -s -I "$CLOUDFRONT_URL" | head -1 | grep -q "200\|301\|302"; then
    echo "   ✅ CloudFront endpoint accessible"
else
    echo "   ❌ CloudFront endpoint not accessible (502 Bad Gateway)"
    echo "   💡 Possible issues:"
    echo "      - S3 website hosting not configured"
    echo "      - Missing index.html file"
    echo "      - Bucket policy issues"
fi

# 7. Show next steps
echo ""
echo "🚀 Recommended Actions:"
if [ "$STATUS" != "Deployed" ]; then
    echo "   ⏳ Wait for CloudFront deployment to complete"
elif [ "$FILE_COUNT" -eq 0 ]; then
    echo "   📦 Deploy files: npm run trigger:aws:s3"
else
    echo "   🔄 Invalidate cache: npm run trigger:aws:s3"
fi

echo ""
echo "🔗 Quick Links:"
echo "   CloudFront: $CLOUDFRONT_URL"
echo "   S3 Direct:  $S3_WEBSITE_URL"