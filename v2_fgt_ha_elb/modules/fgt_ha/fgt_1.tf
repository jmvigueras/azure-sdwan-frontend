##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################
resource "azurerm_virtual_machine" "fgt_1" {
  name                         = "${var.prefix}-${var.fgt_1_id}"
  location                     = var.location
  zones                        = [var.zone]
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [local.fgt_1_ni_ids[var.fgt_ni_0], local.fgt_1_ni_ids[var.fgt_ni_1], local.fgt_1_ni_ids[var.fgt_ni_2]]
  primary_network_interface_id = local.fgt_1_ni_ids[var.fgt_ni_0]
  vm_size                      = var.size

  lifecycle {
    ignore_changes = [os_profile]
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.fgt_offer
    sku       = var.fgt_sku[var.license_type]
    version   = var.fgt_version
  }

  plan {
    publisher = var.publisher
    product   = var.fgt_offer
    name      = var.fgt_sku[var.license_type]
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk-${var.fgt_1_id}-${random_string.random.result}"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-datadisk-${var.fgt_1_id}-${random_string.random.result}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.fgt_1_id}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = data.template_file.fgt_1_config.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage-account_endpoint
  }

  tags = var.tags
}

# Random string to add at disk name
resource "random_string" "random" {
  length  = 5
  special = false
  numeric = false
  upper   = false
}

// FGT config
data "template_file" "fgt_1_config" {
  template = file("${path.module}/templates/fgt-all.conf")
  vars = {
    fgt_id        = var.fgt_1_id
    admin_port    = var.admin_port
    admin_cidr    = var.admin_cidr
    adminusername = "admin"
    type          = var.license_type
    license_file  = var.fgt_1_license_file

    public_port  = var.ports["public"]
    public_ip    = local.fgt_1_ni_ips["public"]
    public_mask  = cidrnetmask(var.subnet_cidrs["public"])
    public_gw    = cidrhost(var.subnet_cidrs["public"], 1)
    private_port = var.ports["private"]
    private_ip   = local.fgt_1_ni_ips["private"]
    private_mask = cidrnetmask(var.subnet_cidrs["private"])
    private_gw   = cidrhost(var.subnet_cidrs["private"], 1)
    mgmt_port    = var.ports["mgmt"]
    mgmt_ip      = local.fgt_1_ni_ips["mgmt"]
    mgmt_mask    = cidrnetmask(var.subnet_cidrs["mgmt"])
    mgmt_gw      = cidrhost(var.subnet_cidrs["mgmt"], 1)

    fgt_fgcp-config  = var.config_fgcp ? data.template_file.fgt_1_fgcp-config.rendered : ""
    fgt_fmg-config   = var.config_fmg ? data.template_file.fgt_fmg-config.rendered : ""
    fgt_faz-config   = var.config_faz ? data.template_file.fgt_faz-config.rendered : ""
    fgt_extra-config = var.fgt_extra_config
  }
}
data "template_file" "fgt_1_fgcp-config" {
  template = file("${path.module}/templates/fgt-ha-fgcp.conf")
  vars = {
    fgt_priority = 200
    mgmt_port    = var.ports["mgmt"]
    ha_port      = var.ports["mgmt"]
    mgmt_gw      = cidrhost(var.subnet_cidrs["mgmt"], 1)
    peerip       = local.fgt_2_ni_ips["mgmt"]
  }
}
data "template_file" "fgt_faz-config" {
  template = file("${path.module}/templates/fgt-faz.conf")
  vars = {
    ip                      = var.faz_ip
    sn                      = var.faz_sn
    source-ip               = var.faz_fgt_source-ip
    interface-select-method = var.faz_interface-select-method
  }
}
data "template_file" "fgt_fmg-config" {
  template = file("${path.module}/templates/fgt-fmg.conf")
  vars = {
    ip                      = var.fmg_ip
    sn                      = var.fmg_sn
    source-ip               = var.fmg_fgt_source-ip
    interface-select-method = var.fmg_interface-select-method
  }
}

#----------------------------------------------------------------------------------
# Create public IPs and interfaces
#----------------------------------------------------------------------------------
// Active MGMT public IP
resource "azurerm_public_ip" "fgt_1_ni_mgmt" {
  name                = local.fgt_1_ni_names["mgmt"]
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Active FGT Network Interface MGMT
resource "azurerm_network_interface" "fgt_1_ni_mgmt" {
  name                          = local.fgt_1_ni_names["mgmt"]
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["mgmt"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_1_ni_ips["mgmt"]
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.fgt_1_ni_mgmt.id
  }

  tags = var.tags
}
// Active FGT Network Interface MGMT
resource "azurerm_network_interface" "fgt_1_ni_public" {
  name                          = local.fgt_1_ni_names["public"]
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["public"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_1_ni_ips["public"]
  }

  tags = var.tags
}
// Active FGT Network Interface Private
resource "azurerm_network_interface" "fgt_1_ni_private" {
  name                          = local.fgt_1_ni_names["private"]
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["private"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_1_ni_ips["private"]
  }

  tags = var.tags
}

#-------------------------------------------------------------------------------------
# Associate NSG to interfaces (Public interfaces FGT)
# - Connect the security group to the network interfaces FGT active
resource "azurerm_network_interface_security_group_association" "fgt_1_ni_mgmt_nsg" {
  network_interface_id      = local.fgt_1_ni_ids["mgmt"]
  network_security_group_id = var.fgt_nsg_ids["mgmt"]
}
resource "azurerm_network_interface_security_group_association" "fgt_1_ni_public_nsg" {
  network_interface_id      = local.fgt_1_ni_ids["public"]
  network_security_group_id = var.fgt_nsg_ids["public"]
}