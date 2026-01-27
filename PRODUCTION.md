# Production Deployment Guide

## Prerequisites
1. GitHub repository with your code
2. GitHub personal access token
3. AWS credentials configured
4. Email for notifications

## Deployment Steps

### 1. Configure Variables
Create `terraform.tfvars`:
```hcl
github_owner = "your-github-username"
github_repo = "your-repo-name"
github_branch = "main"
github_token = "ghp_your_token_here"
notification_email = "your-email@company.com"
```

### 2. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 3. Confirm Email Subscription
Check your email and confirm the SNS subscription.

## Production Features

✅ **GitHub Integration** - Automatic triggers on push
✅ **Email Notifications** - Alerts on pipeline failures  
✅ **Secret Detection** - TruffleHog scanning
✅ **S3 Artifact Storage** - Scan results preserved
✅ **IAM Security** - Least privilege access
✅ **No Test Files** - Clean production code

## Pipeline Flow
```
GitHub Push → CodePipeline → TruffleHog Scan → Pass/Fail → Email Alert
```

## Monitoring
- **AWS Console**: CodePipeline dashboard
- **S3 Bucket**: `ml-secrets-demo-artifacts-*` for scan results
- **Email**: Failure notifications

## Security
- Secrets stored in AWS Secrets Manager
- No hardcoded credentials in code
- Automated security scanning on every commit