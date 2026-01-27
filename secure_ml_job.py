import boto3
import json
import os
from botocore.exceptions import ClientError

class SecureMLConfig:
    def __init__(self):
        self.secrets_client = boto3.client('secretsmanager')
        self.ssm_client = boto3.client('ssm')
    
    def get_secret(self, secret_name):
        """Retrieve secret from AWS Secrets Manager"""
        try:
            response = self.secrets_client.get_secret_value(SecretId=secret_name)
            return json.loads(response['SecretString'])
        except ClientError as e:
            print(f"Error retrieving secret: {e}")
            return None
    
    def get_parameter(self, parameter_name):
        """Retrieve parameter from AWS Systems Manager Parameter Store"""
        try:
            response = self.ssm_client.get_parameter(Name=parameter_name)
            return json.loads(response['Parameter']['Value'])
        except ClientError as e:
            print(f"Error retrieving parameter: {e}")
            return None

def main():
    config_manager = SecureMLConfig()
    
    # Get secrets and configuration dynamically
    secret_name = 'ml-secrets-demo/api-key-v2'
    parameter_name = '/ml-secrets-demo/config'
    
    api_secrets = config_manager.get_secret(secret_name)
    ml_config = config_manager.get_parameter(parameter_name)
    
    if not api_secrets or not ml_config:
        print("Failed to retrieve configuration. Exiting.")
        return
    
    # Use the secrets securely
    api_key = api_secrets.get('api_key')
    endpoint = api_secrets.get('endpoint')
    
    model_name = ml_config.get('model_name')
    batch_size = ml_config.get('batch_size')
    max_epochs = ml_config.get('max_epochs')
    
    print(f"Starting ML job with model: {model_name}")
    print(f"Batch size: {batch_size}, Max epochs: {max_epochs}")
    print(f"API endpoint: {endpoint}")
    print("API key retrieved securely from Secrets Manager")
    
    print("Training model with secure configuration...")
    print("ML job completed successfully!")

if __name__ == "__main__":
    main()