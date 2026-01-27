# Secret Detection Pipeline

Automated secret detection using AWS CodePipeline and TruffleHog.

## Features
- 🔍 **TruffleHog scanning** on every commit
- 🚨 **Email notifications** on failures  
- 📊 **Scan results** stored in S3
- 🔒 **AWS Secrets Manager** integration
- ⚡ **GitHub Actions** + **CodePipeline**

## Quick Start

1. **Clone and setup:**
```bash
git clone https://github.com/USERNAME/REPO.git
cd REPO
```

2. **Configure:**
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your details
```

3. **Deploy:**
```bash
terraform init
terraform apply
```

## Architecture
```
GitHub → CodePipeline → TruffleHog → Pass/Fail → Email Alert
```

## Security
✅ No hardcoded secrets  
✅ Automated scanning  
✅ Fail-fast on detection  
✅ Audit trail in S3