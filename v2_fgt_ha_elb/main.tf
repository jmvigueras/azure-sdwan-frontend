#------------------------------------------------------------------
# Create FGT in zone 1
#------------------------------------------------------------------
module "fgt_zone_1" {
  count  = local.fgt_number_zone1
  source = "./modules/fgt_ha"

  prefix                   = local.prefix
  suffix                   = count.index
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint

  admin_username = local.admin_username
  admin_password = local.admin_password
  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port

  license_type       = local.license_type
  fgt_1_license_file = "${local.license_path}license${count.index * 2 + 1}.lic"
  fgt_2_license_file = "${local.license_path}license${count.index * 2 + 2}.lic"

  fgt_version  = local.fgt_version
  size         = local.fgt_size
  zone         = local.location_zones[0]
  fgt_1_id     = "ac-${count.index + 1}-fgt-1"
  fgt_2_id     = "ac-${count.index + 1}-fgt-2"
  fgt_cidrhost = count.index * 2 + 10
  subnet_cidrs = module.fgt_vnet.subnet_cidrs
  subnet_ids   = module.fgt_vnet.subnet_ids
  fgt_nsg_ids  = module.fgt_vnet.nsg_ids

  config_fmg = true
  config_faz = true

  fmg_ip = local.fmg_ip
  faz_ip = local.faz_ip
}
// Create load balancers
module "elb_zone_1" {
  count  = local.fgt_number_zone1
  source = "./modules/elb"

  prefix              = "${local.prefix}-ac-${count.index + 1}"
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  backend-probe_port = "8008"

  vnet_fgt = module.fgt_vnet.vnet
  fgt_1_ip = cidrhost(module.fgt_vnet.subnet_cidrs["public"], count.index * 2 + 10)
  fgt_2_ip = cidrhost(module.fgt_vnet.subnet_cidrs["public"], count.index * 2 + 11)

  elb_listeners = {
    "500"  = "Udp"
    "4500" = "Udp"
  }
}
#------------------------------------------------------------------
# Create FGT in zone 2
#------------------------------------------------------------------
module "fgt_zone_2" {
  count  = local.fgt_number_zone2
  source = "./modules/fgt_ha"

  prefix                   = local.prefix
  suffix                   = count.index
  location                 = local.location
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                     = local.tags
  storage-account_endpoint = local.storage-account_endpoint == null ? azurerm_storage_account.storageaccount[0].primary_blob_endpoint : local.storage-account_endpoint

  admin_username = local.admin_username
  admin_password = local.admin_password
  admin_cidr     = local.admin_cidr
  admin_port     = local.admin_port

  license_type       = local.license_type
  fgt_1_license_file = "${local.license_path}license${count.index * 2 + length(module.fgt_zone_1) * 2 + 1}.lic"
  fgt_2_license_file = "${local.license_path}license${count.index * 2 + length(module.fgt_zone_1) * 2 + 2}.lic"

  fgt_version  = local.fgt_version
  size         = local.fgt_size
  zone         = local.location_zones[1]
  fgt_1_id     = "ac-${count.index + 1 + length(module.fgt_zone_1)}-fgt-1"
  fgt_2_id     = "ac-${count.index + 1 + length(module.fgt_zone_1)}-fgt-2"
  fgt_cidrhost = count.index * 2 + 10 + length(module.fgt_zone_1) * 2
  subnet_cidrs = module.fgt_vnet.subnet_cidrs
  subnet_ids   = module.fgt_vnet.subnet_ids
  fgt_nsg_ids  = module.fgt_vnet.nsg_ids

  config_fmg = true
  config_faz = true

  fmg_ip = local.fmg_ip
  faz_ip = local.faz_ip
}
// Create load balancers
module "elb_zone_2" {
  count  = local.fgt_number_zone2
  source = "./modules/elb"

  prefix              = "${local.prefix}-ac-${count.index + 1 + length(module.fgt_zone_1)}"
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  backend-probe_port = "8008"

  vnet_fgt = module.fgt_vnet.vnet
  fgt_1_ip = cidrhost(module.fgt_vnet.subnet_cidrs["public"], 10 + count.index * 2 + length(module.fgt_zone_1) * 2)
  fgt_2_ip = cidrhost(module.fgt_vnet.subnet_cidrs["public"], 11 + count.index * 2 + length(module.fgt_zone_1) * 2)

  elb_listeners = {
    "500"  = "Udp"
    "4500" = "Udp"
  }
}

#------------------------------------------------------------------
# Create vNET
#------------------------------------------------------------------
module "fgt_vnet" {
  source = "./modules/vnet-fgt"

  prefix              = local.prefix
  location            = local.location
  resource_group_name = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  tags                = local.tags

  admin_cidr = local.admin_cidr
  admin_port = local.admin_port

  vnet_cidr = local.fgt_vnet_cidr
}


#-----------------------------------------------------------------------
# Necessary resources if not provided
#-----------------------------------------------------------------------
// Create storage account if not provided
resource "random_id" "randomId" {
  count       = local.storage-account_endpoint == null ? 1 : 0
  byte_length = 8
}
resource "azurerm_storage_account" "storageaccount" {
  count                    = local.storage-account_endpoint == null ? 1 : 0
  name                     = "stgra${random_id.randomId[count.index].hex}"
  resource_group_name      = local.resource_group_name == null ? azurerm_resource_group.rg[0].name : local.resource_group_name
  location                 = local.location
  account_replication_type = "LRS"
  account_tier             = "Standard"
  min_tls_version          = "TLS1_2"

  tags = local.tags
}
// Create Resource Group if it is null
resource "azurerm_resource_group" "rg" {
  count    = local.resource_group_name == null ? 1 : 0
  name     = "${local.prefix}-rg"
  location = local.location

  tags = local.tags
}

#-----------------------------------------------------------------------
# Optional resources
#-----------------------------------------------------------------------
data "http" "my-public-ip" {
  url = "http://ifconfig.me/ip"
}
/*
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${local.prefix}-ssh-key.pem"
  file_permission = "0600"
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}
*/