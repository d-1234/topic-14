#!/usr/bin/env powershell

# Create source code zip using PowerShell
Write-Host "Creating source code zip..."
$exclude = @("*.git*", "*.terraform*", "source-code.zip", "terraform.tfstate*")
Get-ChildItem -Path . -Recurse | Where-Object { 
    $item = $_
    -not ($exclude | Where-Object { $item.Name -like $_ })
} | Compress-Archive -DestinationPath "source-code.zip" -Force

# Use hardcoded values since terraform command not available
$SOURCE_BUCKET = "ml-secrets-demo-source-52e4f851"
$PIPELINE_NAME = "ml-secrets-demo-pipeline"

Write-Host "Uploading to S3 bucket: $SOURCE_BUCKET"
aws s3 cp source-code.zip "s3://$SOURCE_BUCKET/source-code.zip"

Write-Host "Starting pipeline: $PIPELINE_NAME"
aws codepipeline start-pipeline-execution --name $PIPELINE_NAME

Remove-Item source-code.zip
Write-Host "Done!"