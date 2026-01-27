#!/bin/bash

echo "=== GitHub Integration Setup ==="

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
fi

# Create .gitignore
echo "Creating .gitignore..."
cat > .gitignore << EOF
# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars

# AWS
.aws/

# Python
__pycache__/
*.pyc
*.pyo

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Temporary files
*.tmp
*.zip
EOF

# Add all files
echo "Adding files to git..."
git add .

# Initial commit
echo "Creating initial commit..."
git commit -m "Initial commit: Secret detection pipeline"

echo ""
echo "Next steps:"
echo "1. Create GitHub repository at https://github.com/new"
echo "2. Run: git remote add origin https://github.com/USERNAME/REPO.git"
echo "3. Run: git push -u origin main"
echo "4. Create terraform.tfvars with your GitHub details"
echo "5. Run: terraform apply"