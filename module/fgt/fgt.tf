##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################
resource "azurerm_virtual_machine" "fgt" {
  name                         = "${var.prefix}-${var.fgt_id}"
  location                     = var.location
  zones                        = [var.zone]
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [local.fgt_ni_ids[var.fgt_ni_0], local.fgt_ni_ids[var.fgt_ni_1], local.fgt_ni_ids[var.fgt_ni_2]]
  primary_network_interface_id = local.fgt_ni_ids[var.fgt_ni_0]
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
    name              = "${var.prefix}-osdisk-${var.fgt_id}-${random_string.random.result}"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-datadisk-${var.fgt_id}-${random_string.random.result}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.fgt_id}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = data.template_file.fgt_config.rendered
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
data "template_file" "fgt_config" {
  template = file("${path.module}/templates/fgt-all.conf")
  vars = {
    fgt_id        = var.fgt_id
    admin_port    = var.admin_port
    admin_cidr    = var.admin_cidr
    adminusername = "admin"
    type          = var.license_type
    license_file  = var.license_file

    public_port  = var.ports["public"]
    public_ip    = local.fgt_ni_ips["public"]
    public_mask  = cidrnetmask(var.subnet_cidrs["public"])
    public_gw    = cidrhost(var.subnet_cidrs["public"], 1)
    private_port = var.ports["private"]
    private_ip   = local.fgt_ni_ips["private"]
    private_mask = cidrnetmask(var.subnet_cidrs["private"])
    private_gw   = cidrhost(var.subnet_cidrs["private"], 1)
    mgmt_port    = var.ports["mgmt"]
    mgmt_ip      = local.fgt_ni_ips["mgmt"]
    mgmt_mask    = cidrnetmask(var.subnet_cidrs["mgmt"])
    mgmt_gw      = cidrhost(var.subnet_cidrs["mgmt"], 1)

    fgt_fmg-config   = var.config_fmg ? data.template_file.fgt_fmg-config.rendered : ""
    fgt_faz-config   = var.config_faz ? data.template_file.fgt_faz-config.rendered : ""
    fgt_extra-config = var.fgt_extra_config
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
