# 🔐 Secret Detection Pipeline

**Automated secret detection using AWS CodePipeline and TruffleHog with multi-layered security protection.**

## 🏗️ Architecture Overview

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│   GitHub    │───▶│ CodePipeline │───▶│  CodeBuild  │───▶│    SNS      │
│ Repository  │    │   (Source)   │    │ (TruffleHog)│    │ (Alerts)    │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
       │                    │                   │                   │
       ▼                    ▼                   ▼                   ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│Push Protection│  │  S3 Bucket   │    │   Results   │    │    Email    │
│  (GitHub)   │    │ (Encrypted)  │    │  Analysis   │    │ Notification│
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
```

## ✨ Features

- 🔍 **TruffleHog scanning** on every commit
- 🚨 **Email notifications** with specific filenames
- 📊 **Scan results** stored in encrypted S3
- 🔒 **AWS Secrets Manager** integration
- ⚡ **GitHub Actions** + **CodePipeline** dual triggers
- 🛡️ **Multi-layered security** (GitHub + AWS)
- 🔐 **KMS encryption** for all artifacts

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- GitHub repository with admin access

### 1. Clone and Configure
```bash
git clone <your-repo-url>
cd topic-14
cp terraform.tfvars.example terraform.tfvars
```

### 2. Update Configuration
Edit `terraform.tfvars`:
```hcl
github_owner = "your-github-username"
github_repo = "your-repository-name"
github_branch = "main"
notification_email = "your-email@company.com"
```

### 3. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 4. Complete GitHub Connection
1. Go to AWS Console → CodePipeline → Settings → Connections
2. Find your connection and click "Update pending connection"
3. Complete GitHub authorization

## 📁 Project Structure

```
├── modules/                    # Terraform modules
│   ├── cicd/                  # CodeBuild configuration
│   ├── iam/                   # IAM roles and policies
│   ├── notifications/         # SNS and CloudWatch Events
│   ├── secrets/              # Secrets Manager and SSM
│   └── storage/              # S3 buckets
├── .github/workflows/        # GitHub Actions
├── buildspec.yml            # CodeBuild build specification
├── codepipeline.tf         # Main pipeline configuration
├── main.tf                 # Root module
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── demo.env               # Demo secrets file
└── SECURITY.md           # Security documentation
```

## 🔧 Configuration

### Variables
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region for resources | `us-east-1` | No |
| `project_name` | Project name for resource naming | `ml-secrets-demo` | No |
| `github_owner` | GitHub repository owner | - | Yes |
| `github_repo` | GitHub repository name | - | Yes |
| `github_branch` | Branch to monitor | `main` | No |
| `notification_email` | Email for alerts | - | Yes |

### Outputs
- `pipeline_name` - CodePipeline name
- `github_connection_arn` - CodeStar connection ARN
- `artifacts_bucket` - S3 artifacts bucket
- `deployment_summary` - Complete deployment info

## 🛡️ Security Features

### Multi-Layer Protection
1. **GitHub Push Protection** - Blocks commits with secrets
2. **Pipeline Scanning** - TruffleHog deep scan
3. **Email Alerts** - Immediate notifications
4. **Audit Trail** - Complete logging

### Encryption & Access Control
- **KMS encryption** for all pipeline artifacts
- **S3 bucket encryption** with public access blocked
- **IAM least privilege** access policies
- **Secrets Manager** for sensitive data

### Monitoring & Compliance
- **CloudWatch logging** for all builds
- **SNS notifications** on failures
- **Resource tagging** for compliance
- **Versioned artifacts** for audit

## 🔍 How It Works

1. **Developer pushes code** → GitHub repository
2. **GitHub scans commit** → Blocks if secrets found
3. **CodeStar triggers pipeline** → Downloads source
4. **CodeBuild runs TruffleHog** → Scans all files
5. **If secrets detected** → Build fails + Email sent
6. **If clean** → Pipeline succeeds

## 📧 Email Notifications

When secrets are detected, you'll receive an email with:
- **Alert message** with severity
- **Specific filenames** containing secrets
- **Build details** and logs link
- **Remediation guidance**

## 🧪 Testing

### Demo Files Included
- `demo.env` - Contains AWS credentials
- `demo_secrets.py` - Python file with secrets
- Both files will trigger detection for demonstration

### Manual Testing
```bash
# Add a secret to test detection
echo "api_key=sk_live_1234567890abcdef" >> test.env
git add test.env
git commit -m "Test secret detection"
git push
```

## 🔧 Troubleshooting

### Common Issues
1. **Pipeline not triggering** - Check CodeStar connection status
2. **Build failing** - Review CloudWatch logs
3. **No email notifications** - Confirm SNS subscription
4. **Permission errors** - Verify IAM roles

### Useful Commands
```bash
# Check pipeline status
aws codepipeline get-pipeline-state --name ml-secrets-demo-pipeline

# View build logs
aws logs describe-log-groups --log-group-name-prefix "/aws/codebuild/ml-secrets-demo"

# Test SNS notification
aws sns publish --topic-arn <topic-arn> --message "Test" --subject "Test Alert"
```

## 🧹 Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Note:** S3 buckets are configured with `force_destroy = true` for easy cleanup.

## 📚 Additional Resources

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [TruffleHog Documentation](https://github.com/trufflesecurity/trufflehog)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**⚠️ Security Note:** This pipeline is designed to prevent secrets from reaching production. Always review and rotate any exposed credentials immediately.