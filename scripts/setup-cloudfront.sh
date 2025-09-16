#!/bin/bash

# CloudFront Setup Script for Single-SPA Microfrontends
# 
# Usage Examples:
#   Action-only (uses default bucket from .env):
#     ./setup-cloudfront.sh basic           # Basic CloudFront distribution
#     ./setup-cloudfront.sh spa             # SPA-optimized distribution
#     ./setup-cloudfront.sh full            # Full setup with custom domain
#     ./setup-cloudfront.sh                 # Same as basic (default)
#
#   Traditional bucket + action:
#     ./setup-cloudfront.sh my-bucket basic # Basic distribution with custom bucket
#     ./setup-cloudfront.sh my-bucket spa   # SPA distribution with custom bucket
#     ./setup-cloudfront.sh my-bucket full  # Full setup with custom bucket
#
# Actions:
#   basic  - Creates basic CloudFront distribution (default)
#   spa    - SPA-optimized: custom error pages, caching rules
#   full   - Full setup: SPA optimization + custom domain + SSL
#
# Environment:
#   Loads S3_BUCKET, AWS_REGION, CUSTOM_DOMAIN from .env

set -euo pipefail

# Load environment variables
load_env() {
    if [ -f ".env" ]; then
        echo "📄 Loading environment variables from .env..."
        export $(grep -v '^#' ".env" | xargs)
    fi
}

load_env

# Parse arguments - handle action-only usage
if [[ "${1:-}" =~ ^(basic|spa|full)$ ]] && [ -z "${2:-}" ]; then
    # First argument is an action, use default bucket
    BUCKET_NAME=${S3_BUCKET}
    ACTION=${1:-basic}
else
    # Standard usage: bucket-name [action]
    BUCKET_NAME=${1:-$S3_BUCKET}
    ACTION=${2:-basic}
fi
REGION=${AWS_REGION:-eu-central-1}
CUSTOM_DOMAIN=${CUSTOM_DOMAIN:-}

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: No bucket name provided and S3_BUCKET not set in .env"
    echo "Usage: ./setup-cloudfront.sh [bucket-name] [action]"
    echo "Actions: basic (default), spa, full"
    exit 1
fi

echo "🚀 CloudFront Setup: $ACTION for bucket $BUCKET_NAME in region $REGION"

# Check if bucket exists
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "❌ Error: S3 bucket $BUCKET_NAME does not exist"
    echo "💡 Run ./setup-s3.sh $BUCKET_NAME public first"
    exit 1
fi

ORIGIN_DOMAIN="$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

create_basic_distribution() {
    echo "📦 Creating basic CloudFront distribution..."
    
    DISTRIBUTION_CONFIG='{
        "CallerReference": "'$(date +%s)'",
        "Comment": "Basic distribution for '$BUCKET_NAME'",
        "DefaultCacheBehavior": {
            "TargetOriginId": "'$BUCKET_NAME'-origin",
            "ViewerProtocolPolicy": "redirect-to-https",
            "TrustedSigners": {
                "Enabled": false,
                "Quantity": 0
            },
            "ForwardedValues": {
                "QueryString": false,
                "Cookies": {"Forward": "none"}
            },
            "MinTTL": 0
        },
        "Origins": {
            "Quantity": 1,
            "Items": [
                {
                    "Id": "'$BUCKET_NAME'-origin",
                    "DomainName": "'$ORIGIN_DOMAIN'",
                    "CustomOriginConfig": {
                        "HTTPPort": 80,
                        "HTTPSPort": 443,
                        "OriginProtocolPolicy": "http-only"
                    }
                }
            ]
        },
        "Enabled": true,
        "PriceClass": "PriceClass_100"
    }'
    
    DISTRIBUTION_ID=$(aws cloudfront create-distribution --distribution-config "$DISTRIBUTION_CONFIG" --query 'Distribution.Id' --output text)
    DOMAIN_NAME=$(aws cloudfront create-distribution --distribution-config "$DISTRIBUTION_CONFIG" --query 'Distribution.DomainName' --output text)
    
    echo "✅ Basic CloudFront distribution created!"
    echo "🆔 Distribution ID: $DISTRIBUTION_ID"
    echo "🌐 CloudFront URL: https://$DOMAIN_NAME"
}

create_spa_distribution() {
    echo "📦 Creating SPA-optimized CloudFront distribution..."
    
    DISTRIBUTION_CONFIG='{
        "CallerReference": "'$(date +%s)'",
        "Comment": "SPA-optimized distribution for '$BUCKET_NAME'",
        "DefaultCacheBehavior": {
            "TargetOriginId": "'$BUCKET_NAME'-origin",
            "ViewerProtocolPolicy": "redirect-to-https",
            "TrustedSigners": {
                "Enabled": false,
                "Quantity": 0
            },
            "ForwardedValues": {
                "QueryString": true,
                "Cookies": {"Forward": "none"},
                "Headers": {
                    "Quantity": 1,
                    "Items": ["Origin"]
                }
            },
            "MinTTL": 0,
            "DefaultTTL": 86400,
            "MaxTTL": 31536000,
            "Compress": true
        },
        "CacheBehaviors": {
            "Quantity": 2,
            "Items": [
                {
                    "PathPattern": "*.js",
                    "TargetOriginId": "'$BUCKET_NAME'-origin",
                    "ViewerProtocolPolicy": "redirect-to-https",
                    "TrustedSigners": {
                        "Enabled": false,
                        "Quantity": 0
                    },
                    "ForwardedValues": {
                        "QueryString": false,
                        "Cookies": {"Forward": "none"}
                    },
                    "MinTTL": 31536000,
                    "Compress": true
                },
                {
                    "PathPattern": "importmap.json",
                    "TargetOriginId": "'$BUCKET_NAME'-origin",
                    "ViewerProtocolPolicy": "redirect-to-https",
                    "TrustedSigners": {
                        "Enabled": false,
                        "Quantity": 0
                    },
                    "ForwardedValues": {
                        "QueryString": false,
                        "Cookies": {"Forward": "none"}
                    },
                    "MinTTL": 0,
                    "DefaultTTL": 300,
                    "MaxTTL": 300,
                    "Compress": true
                }
            ]
        },
        "CustomErrorResponses": {
            "Quantity": 1,
            "Items": [
                {
                    "ErrorCode": 404,
                    "ResponsePagePath": "/index.html",
                    "ResponseCode": "200",
                    "ErrorCachingMinTTL": 300
                }
            ]
        },
        "Origins": {
            "Quantity": 1,
            "Items": [
                {
                    "Id": "'$BUCKET_NAME'-origin",
                    "DomainName": "'$ORIGIN_DOMAIN'",
                    "CustomOriginConfig": {
                        "HTTPPort": 80,
                        "HTTPSPort": 443,
                        "OriginProtocolPolicy": "http-only"
                    }
                }
            ]
        },
        "Enabled": true,
        "PriceClass": "PriceClass_100"
    }'
    
    DISTRIBUTION_ID=$(aws cloudfront create-distribution --distribution-config "$DISTRIBUTION_CONFIG" --query 'Distribution.Id' --output text)
    DOMAIN_NAME=$(aws cloudfront create-distribution --distribution-config "$DISTRIBUTION_CONFIG" --query 'Distribution.DomainName' --output text)
    
    echo "✅ SPA-optimized CloudFront distribution created!"
    echo "🆔 Distribution ID: $DISTRIBUTION_ID"
    echo "🌐 CloudFront URL: https://$DOMAIN_NAME"
    echo "🔧 Features: Custom error pages, JS caching, import map optimization"
}

create_full_distribution() {
    if [ -z "$CUSTOM_DOMAIN" ]; then
        echo "⚠️  CUSTOM_DOMAIN not set in .env, creating SPA distribution without custom domain"
        create_spa_distribution
        return
    fi
    
    echo "📦 Creating full CloudFront distribution with custom domain..."
    echo "🌐 Custom domain: $CUSTOM_DOMAIN"
    echo "⚠️  Note: You need to have SSL certificate in ACM for $CUSTOM_DOMAIN"
    
    # This would require SSL certificate ARN - simplified for now
    echo "💡 For custom domain setup, please:"
    echo "   1. Create SSL certificate in AWS Certificate Manager"
    echo "   2. Update DNS to point to CloudFront"
    echo "   3. Use AWS Console for custom domain configuration"
    
    create_spa_distribution
}

update_env_file() {
    if [ -n "${DISTRIBUTION_ID:-}" ]; then
        echo "📝 Updating .env file with Distribution ID..."
        
        if grep -q "CLOUDFRONT_DISTRIBUTION_ID=" .env; then
            # Update existing line
            sed -i "s/CLOUDFRONT_DISTRIBUTION_ID=.*/CLOUDFRONT_DISTRIBUTION_ID=$DISTRIBUTION_ID/" .env
        else
            # Add new line
            echo "CLOUDFRONT_DISTRIBUTION_ID=$DISTRIBUTION_ID" >> .env
        fi
        
        echo "✅ Updated .env with CLOUDFRONT_DISTRIBUTION_ID=$DISTRIBUTION_ID"
    fi
}

wait_for_deployment() {
    if [ -n "${DISTRIBUTION_ID:-}" ]; then
        echo "⏳ Waiting for CloudFront distribution to deploy (this may take 10-15 minutes)..."
        echo "💡 You can continue with other tasks - deployment happens in background"
        echo "🔍 Check status: aws cloudfront get-distribution --id $DISTRIBUTION_ID"
    fi
}

show_results() {
    echo ""
    echo "🎉 CloudFront configuration complete!"
    echo "📍 Bucket: $BUCKET_NAME"
    echo "🆔 Distribution ID: ${DISTRIBUTION_ID:-N/A}"
    echo "🌐 CloudFront URL: https://${DOMAIN_NAME:-N/A}"
    echo "⏳ Status: Deploying (10-15 minutes)"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Wait for deployment to complete"
    echo "   2. Test your microfrontends via CloudFront URL"
    echo "   3. Use 'npm run trigger:aws:s3' for deployments with cache invalidation"
}

# Execute based on action
case $ACTION in
    "basic")
        create_basic_distribution
        update_env_file
        wait_for_deployment
        show_results
        ;;
    "spa")
        create_spa_distribution
        update_env_file
        wait_for_deployment
        show_results
        ;;
    "full")
        create_full_distribution
        update_env_file
        wait_for_deployment
        show_results
        ;;
    *)
        echo "❌ Invalid action: $ACTION"
        echo "Available actions: basic, spa (recommended), full"
        exit 1
        ;;
esac