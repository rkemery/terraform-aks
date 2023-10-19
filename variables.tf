variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "cluster_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "cluster_k8s_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
}

variable "cluster_admin_username" {
  description = "Admin username for the AKS cluster"
  type        = string
}

variable "agent_pool_name" {
  description = "Name of the agent pool"
  type        = string
}

variable "agent_pool_count" {
  description = "Number of nodes in the agent pool"
  type        = number
}

variable "agent_pool_vm_size" {
  description = "VM size for the agent pool"
  type        = string
}   

variable "agent_pool_os_disk_size" {
  description = "OS disk size for the agent pool"
  type        = number
}

variable "client_id" {
  description = "Client ID for the service principal"
  type        = string
}

variable "client_secret" {
  description = "Client secret for the service principal"
  type        = string
}

variable "cluster_ssh_key" {
  description = "SSH key for the AKS cluster"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

variable "aks_vnet_address_space" {
  description = "Address space for the AKS cluster VNet"
  type        = list(string)
}

variable "appgw_vnet_address_space" {
  description = "Address space for the App Gateway VNet"
  type        = list(string)
}

variable "aks_subnet_address_prefixes" {
  description = "Address prefixes for the AKS cluster subnet"
  type        = list(string)
}

variable "appgw_subnet_address_prefixes" {
  description = "Address prefixes for the App Gateway subnet"
  type        = list(string)
}

variable "prefix" {
  description = "Prefix for the AKS cluster"
  type        = string
}

variable "app_gateway_sku" {
  description = "SKU for the App Gateway"
  type        = string
}

variable "maintenance_window_day" {
  description = "Day of the week for the maintenance window"
  type        = string
}

variable "maintenance_window_hours" {
  description = "Hour of the day for the maintenance window"
  type        = list(string)
}

variable "user_pool_vm_size" {
  description = "VM size for the user pool"
  type        = string
}

variable "app_gateway_tier" {
  description = "Tier for the App Gateway"
  type        = string
}

variable "app_gateway_capacity" {
  description = "Capacity for the App Gateway"
  type        = number
}

variable "cluster_auto_channel_upgrade" {
  description = "Enable auto channel upgrade for the AKS cluster"
  type        = string
}

variable "cluster_zones" {
  description = "Availability zones for the AKS cluster"
  type        = list(string)
}

variable "cluster_min_count" {
  description = "Minimum number of nodes for the AKS cluster"
  type        = number
}

variable "cluster_max_count" {
  description = "Maximum number of nodes for the AKS cluster"
  type        = number
}

variable "np01_zones" {
  description = "Availability zones for the first node pool"
  type        = list(string)
}

variable "np01_min_count" {
  description = "Minimum number of nodes for the first node pool"
  type        = number
}

variable "np01_max_count" {
  description = "Maximum number of nodes for the first node pool"
  type        = number
}