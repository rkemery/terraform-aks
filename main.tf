resource "azurerm_resource_group" "aks_rg" {
  name     = var.rg_name
  location = var.location
}

resource "azuread_group" "aks_admins" {
  display_name     = "${var.prefix}-admins"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
  members = ["${data.azuread_user.administrator.object_id}","${data.azuread_service_principal.terraform.object_id}","${azurerm_user_assigned_identity.aks_mid.principal_id}"]

  depends_on = [
    azurerm_user_assigned_identity.aks_mid, data.azuread_user.administrator, data.azuread_service_principal.terraform
  ]
}

resource "azurerm_key_vault" "aks_kv" {
  name                        = "${var.prefix}-kv"
  location                    = azurerm_resource_group.aks_rg.location
  resource_group_name         = azurerm_resource_group.aks_rg.name
  #enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  #purge_protection_enabled    = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azuread_group.aks_admins.object_id

    key_permissions = [
      "Get", "List", "Create", "Update", "Import", "Delete", "Recover", "Backup", "Restore", "Purge", "Decrypt", "Encrypt", "Sign", "Verify", "WrapKey", "UnwrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy",
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge",
    ]

    storage_permissions = [ 
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update",
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Update", "Import", "Delete", "Recover", "Backup", "Restore", "Purge",
    ]
  }
}

resource "azurerm_key_vault_key" "aks_key" {
  name         = "${var.prefix}-key"
  key_vault_id = azurerm_key_vault.aks_kv.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_key_vault_key" "aks_disk_encryption" {
  name         = "${var.prefix}-dek"
  key_vault_id = azurerm_key_vault.aks_kv.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# resource "azurerm_disk_encryption_set" "aks_des" {
#   name                = "${var.prefix}-des"
#   resource_group_name = azurerm_resource_group.aks_rg.name
#   location            = azurerm_resource_group.aks_rg.location
#   key_vault_key_id    = "https://${azurerm_key_vault.aks_kv.name}.vault.azure.net/keys/${azurerm_key_vault_key.aks_disk_encryption.name}/${azurerm_key_vault_key.aks_disk_encryption.version}"

#   identity {
#     type = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.aks_mid.id]
#   }
# }

resource "azurerm_user_assigned_identity" "aks_mid" {
  location            = azurerm_resource_group.aks_rg.location
  name                = "${var.prefix}-mid"
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_log_analytics_workspace" "aks_log_analytics_workspace" {
  name                = "${var.prefix}-law"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "aks_log_analytics_solution" {
  solution_name         = "Containers"
  workspace_resource_id = azurerm_log_analytics_workspace.aks_log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.aks_log_analytics_workspace.name
  location              = azurerm_resource_group.aks_rg.location
  resource_group_name   = azurerm_resource_group.aks_rg.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.prefix}-aksvnet"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = var.aks_vnet_address_space
}

resource "azurerm_virtual_network" "appgw_vnet" {
  name                = "${var.prefix}-appgwvnet"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = var.appgw_vnet_address_space
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.prefix}-akssubnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = var.aks_subnet_address_prefixes
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "${var.prefix}-appgwsubnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = var.appgw_subnet_address_prefixes
  virtual_network_name = azurerm_virtual_network.appgw_vnet.name
}

resource "azurerm_public_ip" "appgw_public_ip" {
  name                         = "${var.prefix}-appgw-pip"
  location                     = azurerm_resource_group.aks_rg.location
  resource_group_name          = azurerm_resource_group.aks_rg.name
  allocation_method            = "Static"
  sku                          = "Standard"
}

resource "azurerm_application_gateway" "aks_appgw" {
  name                = "${var.prefix}-appgw"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location

  sku {
    name     = var.app_gateway_sku
    tier     = var.app_gateway_tier
    capacity = var.app_gateway_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "${var.prefix}-appgwfrntendport"
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-appgwfrntendipconfig"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

  backend_address_pool {
    name = "${var.prefix}-appgwbackendaddresspool"
  }

  backend_http_settings {
    name                  = "${var.prefix}-appgwbackendhttpsettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = "${var.prefix}-appgwhttplistener"
    frontend_ip_configuration_name = "${var.prefix}-appgwfrntendipconfig"
    frontend_port_name             = "${var.prefix}-appgwfrntendport"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.prefix}-appgwrequestroutingrule"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-appgwhttplistener"
    backend_address_pool_name  = "${var.prefix}-appgwbackendaddresspool"
    backend_http_settings_name = "${var.prefix}-appgwbackendhttpsettings"
    priority = 100
  }

  depends_on = [
    azurerm_virtual_network.appgw_vnet,
    azurerm_public_ip.appgw_public_ip,
  ]
}

resource "random_string" "aks_temporary_name_for_rotation" {
  length = 6
  special = false
  upper = false
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.cluster_dns_prefix
  kubernetes_version  = var.cluster_k8s_version
  http_application_routing_enabled = true
  #disk_encryption_set_id = azurerm_disk_encryption_set.aks_des.id
  azure_policy_enabled = false
  public_network_access_enabled = true
  automatic_channel_upgrade = var.cluster_auto_channel_upgrade
  open_service_mesh_enabled = false
  # image_cleaner_enabled = true
  # image_cleaner_interval_hours = 24
  linux_profile {
    admin_username    = var.cluster_admin_username

    ssh_key {
      key_data = var.cluster_ssh_key
      }
  }

  default_node_pool {
    name            = var.agent_pool_name
    temporary_name_for_rotation = "${var.prefix}${random_string.aks_temporary_name_for_rotation.id}"
    node_count      = var.agent_pool_count
    vm_size         = var.agent_pool_vm_size
    os_disk_size_gb = var.agent_pool_os_disk_size
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    enable_auto_scaling = true
    max_count = var.cluster_max_count
    min_count = var.cluster_min_count
    zones = var.cluster_zones

    upgrade_settings {
      max_surge = "30"
    }
  }

  storage_profile {
    blob_driver_enabled = true
    disk_driver_enabled = true
    disk_driver_version = "v1"
    file_driver_enabled = true
    snapshot_controller_enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_log_analytics_workspace.id
  }

  key_management_service {
    key_vault_key_id = "https://${azurerm_key_vault.aks_kv.name}.vault.azure.net/keys/${azurerm_key_vault_key.aks_key.name}/${azurerm_key_vault_key.aks_key.version}"
  }

  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = [azuread_group.aks_admins.id]
    azure_rbac_enabled = true
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_mid.id]
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks_log_analytics_workspace.id
    msi_auth_for_monitoring_enabled = true
  }

  ingress_application_gateway {
    gateway_id   = azurerm_application_gateway.aks_appgw.id
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
  }

  maintenance_window {
    allowed {
      day = var.maintenance_window_day
      hours = var.maintenance_window_hours
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups = true
    expander = "most-pods"
  }

  depends_on = [azurerm_resource_group.aks_rg, azurerm_key_vault.aks_kv, azurerm_key_vault_key.aks_key, random_string.aks_temporary_name_for_rotation]

  tags = {
    Description = "System pool for AKS cluster"
  }  
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_cluster_node_pool_01" {
  name                  = "${var.prefix}np01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = var.user_pool_vm_size
  node_count            = 3
  enable_auto_scaling   = true
  os_disk_size_gb = var.agent_pool_os_disk_size
  #priority = "Spot"
  #eviction_policy = "Delete"
  #spot_max_price  = 0.5
  zones = var.np01_zones
  max_count = var.np01_max_count
  min_count = var.np01_min_count

  #node_labels = {
  #  "kubernetes.azure.com/scalesetpriority" = "spot"
  #  }
  #node_taints = [
  #  "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  #  ]

  tags = {
    Description = "node pool 01 for AKS cluster"
  }
}
