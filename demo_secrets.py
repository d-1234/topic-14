#!/usr/bin/env python3
"""
Demo file with intentional secrets for testing the pipeline
WARNING: These are fake credentials for demonstration only
"""

import os
import boto3

# AWS Access Key (will be detected)
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# GitHub Token (will be detected)
GITHUB_TOKEN = "ghp_1234567890abcdef1234567890abcdef12345678"

# Database connection string (will be detected)
DATABASE_URL = "postgresql://user:password123@localhost:5432/mydb"

# API Key patterns (will be detected)
STRIPE_API_KEY = "sk_test_1234567890abcdef1234567890abcdef"
SENDGRID_API_KEY = "SG.1234567890abcdef.1234567890abcdef1234567890abcdef"

# JWT Secret (will be detected)
JWT_SECRET = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ"

# Private key (will be detected)
PRIVATE_KEY = """-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1234567890abcdef1234567890abcdef1234567890abcdef
1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
-----END RSA PRIVATE KEY-----"""

def connect_to_services():
    """Demo function using the secrets"""
    # This would normally use the secrets above
    print("Connecting to AWS...")
    print("Connecting to database...")
    print("Authenticating with APIs...")

if __name__ == "__main__":
    connect_to_services()