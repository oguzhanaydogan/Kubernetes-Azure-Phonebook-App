terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.45.0"
    }
  }
   backend "azurerm" {
    resource_group_name  = "ssh-key-rg"
    storage_account_name = "mybackendterraformstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
  
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.prefix}"

  default_node_pool {
    name       = var.prefix
    node_count = 1
    vm_size    = "Standard_D2as_v4"
  }

  identity {
     type = "SystemAssigned"
  }
}
