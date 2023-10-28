locals {
  # ----------------------------------------------------------------------------------
  # FGT (UPDATE IF NEEDED)
  # ----------------------------------------------------------------------------------
  fgt_ni_ips = {
    mgmt    = cidrhost(var.subnet_cidrs["mgmt"], var.fgt_cidrhost)
    public  = cidrhost(var.subnet_cidrs["public"], var.fgt_cidrhost)
    private = cidrhost(var.subnet_cidrs["private"], var.fgt_cidrhost)
  }

  fgt_ni_ids = {
    mgmt    = azurerm_network_interface.ni_mgmt.id
    public  = azurerm_network_interface.ni_public.id
    private = azurerm_network_interface.ni_private.id
  }

  fgt_ni_names = {
    mgmt    = "${var.prefix}-mgmt-${var.fgt_id}"
    public  = "${var.prefix}-public-${var.fgt_id}"
    private = "${var.prefix}-private-${var.fgt_id}"
  }
}