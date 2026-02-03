#!/bin/bash

# Security Validation Script for Secret Detection Pipeline
# Run this after deployment to verify security configurations

set -e

PROJECT_NAME=${1:-"ml-secrets-demo"}
AWS_REGION=${2:-"us-east-1"}

echo "🔍 Security Validation for Project: $PROJECT_NAME"
echo "=================================================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS CLI not configured or no permissions"
    exit 1
fi

echo "✅ AWS CLI configured"

# Validate S3 bucket security
echo ""
echo "🪣 Checking S3 bucket security..."

ARTIFACTS_BUCKET=$(aws s3api list-buckets --query "Buckets[?contains(Name, '$PROJECT_NAME-artifacts')].Name" --output text)
SOURCE_BUCKET=$(aws s3api list-buckets --query "Buckets[?contains(Name, '$PROJECT_NAME-source')].Name" --output text)

if [ -n "$ARTIFACTS_BUCKET" ]; then
    # Check encryption
    if aws s3api get-bucket-encryption --bucket "$ARTIFACTS_BUCKET" &>/dev/null; then
        echo "✅ Artifacts bucket encryption enabled"
    else
        echo "❌ Artifacts bucket encryption not enabled"
    fi
    
    # Check public access block
    if aws s3api get-public-access-block --bucket "$ARTIFACTS_BUCKET" --query 'PublicAccessBlockConfiguration.BlockPublicAcls' --output text | grep -q "True"; then
        echo "✅ Artifacts bucket public access blocked"
    else
        echo "❌ Artifacts bucket public access not blocked"
    fi
else
    echo "❌ Artifacts bucket not found"
fi

# Validate IAM roles
echo ""
echo "👤 Checking IAM roles..."

CODEBUILD_ROLE="$PROJECT_NAME-codebuild-role"
CODEPIPELINE_ROLE="$PROJECT_NAME-codepipeline-role"

if aws iam get-role --role-name "$CODEBUILD_ROLE" &>/dev/null; then
    echo "✅ CodeBuild role exists"
    
    # Check for overly permissive policies
    POLICIES=$(aws iam list-attached-role-policies --role-name "$CODEBUILD_ROLE" --query 'AttachedPolicies[].PolicyArn' --output text)
    if echo "$POLICIES" | grep -q "AdministratorAccess\|PowerUserAccess"; then
        echo "⚠️  CodeBuild role has overly permissive policies"
    else
        echo "✅ CodeBuild role permissions look appropriate"
    fi
else
    echo "❌ CodeBuild role not found"
fi

# Validate Secrets Manager
echo ""
echo "🔐 Checking Secrets Manager..."

SECRET_NAME="$PROJECT_NAME/api-key-v2"
if aws secretsmanager describe-secret --secret-id "$SECRET_NAME" &>/dev/null; then
    echo "✅ Secrets Manager secret exists"
    
    # Check if it's still using placeholder
    SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query 'SecretString' --output text)
    if echo "$SECRET_VALUE" | grep -q "PLACEHOLDER"; then
        echo "⚠️  Secret still contains placeholder - update with real values"
    else
        echo "✅ Secret appears to be updated"
    fi
else
    echo "❌ Secrets Manager secret not found"
fi

# Validate CodePipeline
echo ""
echo "🚀 Checking CodePipeline..."

PIPELINE_NAME="$PROJECT_NAME-pipeline"
if aws codepipeline get-pipeline --name "$PIPELINE_NAME" &>/dev/null; then
    echo "✅ CodePipeline exists"
    
    # Check if KMS encryption is configured
    ENCRYPTION=$(aws codepipeline get-pipeline --name "$PIPELINE_NAME" --query 'pipeline.artifactStore.encryptionKey' --output text)
    if [ "$ENCRYPTION" != "None" ] && [ "$ENCRYPTION" != "null" ]; then
        echo "✅ Pipeline artifacts encrypted"
    else
        echo "❌ Pipeline artifacts not encrypted"
    fi
else
    echo "❌ CodePipeline not found"
fi

# Validate SNS topic
echo ""
echo "📧 Checking SNS notifications..."

TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, '$PROJECT_NAME-pipeline-notifications')].TopicArn" --output text)
if [ -n "$TOPIC_ARN" ]; then
    echo "✅ SNS topic exists"
    
    # Check subscriptions
    SUBSCRIPTIONS=$(aws sns list-subscriptions-by-topic --topic-arn "$TOPIC_ARN" --query 'Subscriptions[].Protocol' --output text)
    if echo "$SUBSCRIPTIONS" | grep -q "email"; then
        echo "✅ Email subscription configured"
    else
        echo "⚠️  No email subscription found"
    fi
else
    echo "❌ SNS topic not found"
fi

# Check CloudWatch logs
echo ""
echo "📊 Checking CloudWatch logs..."

LOG_GROUP="/aws/codebuild/$PROJECT_NAME-security-scan"
if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --query 'logGroups[0].logGroupName' --output text | grep -q "$LOG_GROUP"; then
    echo "✅ CloudWatch log group exists"
else
    echo "❌ CloudWatch log group not found"
fi

echo ""
echo "=================================================="
echo "🎯 Security validation complete!"
echo ""
echo "Next steps:"
echo "1. Update Secrets Manager with real API keys"
echo "2. Confirm SNS email subscription"
echo "3. Test pipeline with a sample commit"
echo "4. Monitor CloudWatch logs for any issues"