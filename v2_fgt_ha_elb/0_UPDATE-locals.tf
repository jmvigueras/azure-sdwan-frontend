locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  resource_group_name      = null           // a new resource group will be created if null
  location                 = "francecentral"
  storage-account_endpoint = null           // a new resource group will be created if null
  prefix                   = "sdwan-access" // prefix added to all resources created

  tags = {
    Deploy  = local.prefix
    Project = "terraform-fortinet"
  }
  #-----------------------------------------------------------------------------------------------------
  # FGT
  #-----------------------------------------------------------------------------------------------------
  admin_port     = "8443"
  admin_cidr     = "${chomp(data.http.my-public-ip.response_body)}/32"
  admin_username = "azureadmin"
  admin_password = "Terraform123#"

  license_type = "byol"
  license_path = "./licenses/" // licenses path folder with licenses files with name licenseX.lic

  fgt_size      = "Standard_F4s"
  fgt_version   = "7.2.6"
  fgt_vnet_cidr = "172.30.0.0/24"

  location_zones     = ["1", "2"] // Zones within region to deploy
  fgt_cluster_number = 2

  fmg_ip = "10.10.10.1"
  faz_ip = "10.10.10.2"
}


