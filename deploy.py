#!/usr/bin/env python3
import zipfile
import os
import subprocess

def create_zip():
    exclude = {'.git', '.terraform', 'terraform.tfstate', 'terraform.tfstate.backup', 'source-code.zip'}
    
    with zipfile.ZipFile('source-code.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk('.'):
            dirs[:] = [d for d in dirs if not any(ex in d for ex in exclude)]
            for file in files:
                if not any(ex in file for ex in exclude):
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, '.')
                    zipf.write(file_path, arcname)
    
    print("Created source-code.zip")

def upload_and_trigger():
    bucket = "ml-secrets-demo-source-52e4f851"
    pipeline = "ml-secrets-demo-pipeline"
    
    # Upload to S3
    subprocess.run(["aws", "s3", "cp", "source-code.zip", f"s3://{bucket}/source-code.zip"])
    
    # Start pipeline
    subprocess.run(["aws", "codepipeline", "start-pipeline-execution", "--name", pipeline])
    
    # Cleanup
    os.remove("source-code.zip")
    print("Pipeline triggered!")

if __name__ == "__main__":
    create_zip()
    upload_and_trigger()