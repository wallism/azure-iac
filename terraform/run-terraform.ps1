# PowerShell script to deploy resources using Terraform
# Navigate to the directory with Terraform files
cd "C:\SprintDeployLearnRepeat\azure-iac\terraform"

# Initialize Terraform (downloads provider plugins)
terraform init

# Validate Terraform configuration
terraform validate

# Plan Terraform execution
terraform plan -out tfplan

# Apply the Terraform configuration
terraform apply "tfplan"

# Output details
Write-Output "Deployment completed."
Write-Output "App Service Name: $(terraform output -raw app_service_name)"
Write-Output "Storage Account Name: $(terraform output -raw storage_account_name)"
Write-Output "User Assigned Identity Name: $(terraform output -raw user_assigned_identity_name)"
