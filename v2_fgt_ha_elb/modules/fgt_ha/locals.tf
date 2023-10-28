locals {
  # ----------------------------------------------------------------------------------
  # FGT (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  fgt_1_ni_ips = {
    mgmt    = cidrhost(var.subnet_cidrs["mgmt"], var.fgt_cidrhost)
    public  = cidrhost(var.subnet_cidrs["public"], var.fgt_cidrhost)
    private = cidrhost(var.subnet_cidrs["private"], var.fgt_cidrhost)
  }

  fgt_1_ni_ids = {
    mgmt    = azurerm_network_interface.fgt_1_ni_mgmt.id
    public  = azurerm_network_interface.fgt_1_ni_public.id
    private = azurerm_network_interface.fgt_1_ni_private.id
  }

  fgt_1_ni_names = {
    mgmt    = "${var.prefix}-mgmt-${var.fgt_1_id}"
    public  = "${var.prefix}-public-${var.fgt_1_id}"
    private = "${var.prefix}-private-${var.fgt_1_id}"
  }

  fgt_2_ni_ips = {
    mgmt    = cidrhost(var.subnet_cidrs["mgmt"], var.fgt_cidrhost + 1)
    public  = cidrhost(var.subnet_cidrs["public"], var.fgt_cidrhost + 1)
    private = cidrhost(var.subnet_cidrs["private"], var.fgt_cidrhost + 1)
  }

  fgt_2_ni_ids = {
    mgmt    = azurerm_network_interface.fgt_2_ni_mgmt.id
    public  = azurerm_network_interface.fgt_2_ni_public.id
    private = azurerm_network_interface.fgt_2_ni_private.id
  }

  fgt_2_ni_names = {
    mgmt    = "${var.prefix}-mgmt-${var.fgt_2_id}"
    public  = "${var.prefix}-public-${var.fgt_2_id}"
    private = "${var.prefix}-private-${var.fgt_2_id}"
  }
}