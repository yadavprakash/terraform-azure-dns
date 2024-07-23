provider "azurerm" {
  features {}
}

locals {
  name        = "yadavprakash"
  environment = "test"
}

module "resource_group" {
  source      = "git::https://github.com/yadavprakash/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = local.name
  environment = local.environment
  location    = "Canada Central"
}


module "vnet" {
  source              = "git::https://github.com/yadavprakash/terraform-azure-vnet.git?ref=v1.0.0"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}


module "dns_zone" {
  depends_on                   = [module.resource_group, module.vnet]
  source                       = "../.."
  name                         = local.name
  environment                  = local.environment
  resource_group_name          = module.resource_group.resource_group_name
  dns_zone_names               = "example0000.com"
  private_registration_enabled = true
  private_dns                  = true
  private_dns_zone_name        = "webserver0000.com"
  virtual_network_id           = module.vnet.vnet_id
  a_records = [{
    name    = "test"
    ttl     = 3600
    records = ["10.0.180.17", "10.0.180.18"]
    },
    {
      name    = "test2"
      ttl     = 3600
      records = ["10.0.180.17", "10.0.180.18"]
  }]

  cname_records = [{
    name   = "test1"
    ttl    = 3600
    record = "example.com"
  }]

  ns_records = [{
    name    = "test2"
    ttl     = 3600
    records = ["ns1.example.com.", "ns2.example.com."]
  }]
}

