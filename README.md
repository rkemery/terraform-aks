# Azure Kubernetes Service (AKS) Configuration using Terraform

This repository contains Terraform scripts to set up and manage an Azure Kubernetes Service (AKS) cluster along with related resources like Azure Active Directory groups, Key Vault, and Application Gateway. The configuration also allows for advanced management of the AKS cluster with the setup of Azure Log Analytics and disk encryption.

## Table of Contents
1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Usage](#usage)

## Features
- **AKS Admin Group Creation:** A dedicated Azure AD group is created for AKS admins. The script uses data sources to fetch the ID of the principal including the run user, to add them as owners and members of the admin group.
- **Key Vault Configuration:** Key Vault is configured with necessary permissions for the AKS admin group. Keys for disk encryption are also generated and managed within the Key Vault.
- **AKS Cluster Setup:** The AKS cluster is set up with configurable parameters for node pools, auto-scaling, and network configurations. It also configures Azure Policy, Azure Monitor, and other optional features for the cluster.
- **Application Gateway Setup:** An Application Gateway is set up for handling ingress traffic to the AKS cluster, with necessary configurations for front-end and back-end pools, listeners, and routing rules.
- **Logging and Monitoring:** Azure Log Analytics workspace and solutions are set up for monitoring container workloads on the AKS cluster.

## Prerequisites
- Azure account with necessary permissions to create and manage resources.
- [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured with necessary Azure credentials.

## Usage
1. Clone the repository:
```bash
git clone https://github.com/your-repository-url
```

2. Navigate to the repository directory:
```bash
cd your-repository-directory
```

3. Initialize Terraform:
```bash
terraform init
```

4. Create a `terraform.tfvars` file with necessary variable values based on the `variables.tf` file.
```hcl
subscription_id = "your-subscription-id"
tenant_id       = "your-tenant-id"
client_id       = "your-client-id"
client_secret   = "your-client-secret"
...
```

5. Plan the Terraform apply:
```bash
terraform plan
```

6. Apply the Terraform configuration:
```bash
terraform apply
```

For customizing the configuration or adding additional resources, modify the Terraform scripts as needed and repeat the plan and apply steps.

