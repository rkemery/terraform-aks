data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

data "azuread_service_principal" "terraform" {
  display_name = "example"
}

data "azuread_user" "administrator" {
  user_principal_name = "example"
}
