#!/bin/bash

# Enable versioning on source bucket
aws s3api put-bucket-versioning --bucket ml-secrets-demo-source-52e4f851 --versioning-configuration Status=Enabled

# Create pipeline using AWS CLI
aws codepipeline create-pipeline --cli-input-json '{
  "pipeline": {
    "name": "ml-secrets-demo-pipeline",
    "roleArn": "arn:aws:iam::361509912577:role/ml-secrets-demo-codepipeline-role",
    "artifactStore": {
      "type": "S3",
      "location": "ml-secrets-demo-artifacts-52e4f851"
    },
    "stages": [
      {
        "name": "Source",
        "actions": [
          {
            "name": "Source",
            "actionTypeId": {
              "category": "Source",
              "owner": "AWS",
              "provider": "S3",
              "version": "1"
            },
            "configuration": {
              "S3Bucket": "ml-secrets-demo-source-52e4f851",
              "S3ObjectKey": "source-code.zip"
            },
            "outputArtifacts": [
              {
                "name": "source_output"
              }
            ]
          }
        ]
      },
      {
        "name": "SecurityScan",
        "actions": [
          {
            "name": "SecurityScan",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "ml-secrets-demo-security-scan"
            },
            "inputArtifacts": [
              {
                "name": "source_output"
              }
            ],
            "outputArtifacts": [
              {
                "name": "scan_output"
              }
            ]
          }
        ]
      },
      {
        "name": "Deploy",
        "actions": [
          {
            "name": "Deploy",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "ml-secrets-demo-terraform-deploy"
            },
            "inputArtifacts": [
              {
                "name": "scan_output"
              }
            ]
          }
        ]
      }
    ]
  }
}'