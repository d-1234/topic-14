#!/bin/bash

# Script to upload source code to S3 and trigger CodePipeline

set -e

echo "Creating source code archive..."
tar --exclude=".git*" --exclude=".terraform*" --exclude="source-code.tar.gz" --exclude="terraform.tfstate*" -czf source-code.tar.gz .

echo "Getting S3 bucket name..."
SOURCE_BUCKET=$(terraform output -raw s3_source_bucket_name)

if [ -z "$SOURCE_BUCKET" ]; then
    echo "Error: Could not get source bucket name. Make sure Terraform has been applied."
    exit 1
fi

echo "Uploading source code to S3 bucket: $SOURCE_BUCKET"
aws s3 cp source-code.tar.gz s3://$SOURCE_BUCKET/source-code.zip

echo "Getting CodePipeline name..."
PIPELINE_NAME=$(terraform output -raw codepipeline_name)

if [ -z "$PIPELINE_NAME" ]; then
    echo "Error: Could not get pipeline name. Make sure Terraform has been applied."
    exit 1
fi

echo "Starting CodePipeline: $PIPELINE_NAME"
aws codepipeline start-pipeline-execution --name $PIPELINE_NAME

echo "Pipeline started successfully!"
echo "Monitor progress at: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/$PIPELINE_NAME/view"

# Clean up
rm source-code.tar.gz
echo "Cleanup completed."