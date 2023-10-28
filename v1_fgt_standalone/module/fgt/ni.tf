#----------------------------------------------------------------------------------
# Create public IPs and interfaces (Active and passive FGT)
#----------------------------------------------------------------------------------
// Active service public IP
resource "azurerm_public_ip" "ni_public" {
  name                = local.fgt_ni_names["public"]
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Active MGMT public IP
resource "azurerm_public_ip" "ni_mgmt" {
  name                = local.fgt_ni_names["mgmt"]
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}
// Active FGT Network Interface MGMT
resource "azurerm_network_interface" "ni_mgmt" {
  name                          = local.fgt_ni_names["mgmt"]
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["mgmt"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_ni_ips["mgmt"]
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.ni_mgmt.id
  }

  tags = var.tags
}
// Active FGT Network Interface MGMT
resource "azurerm_network_interface" "ni_public" {
  name                          = local.fgt_ni_names["public"]
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["public"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_ni_ips["public"]
    public_ip_address_id          = azurerm_public_ip.ni_public.id
  }

  tags = var.tags
}
// Active FGT Network Interface Private
resource "azurerm_network_interface" "ni_private" {
  name                          = local.fgt_ni_names["private"]
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_ids["private"]
    private_ip_address_allocation = "Static"
    private_ip_address            = local.fgt_ni_ips["private"]
  }

  tags = var.tags
}

#-------------------------------------------------------------------------------------
# Associate NSG to interfaces (Public interfaces FGT)
# - Connect the security group to the network interfaces FGT active
resource "azurerm_network_interface_security_group_association" "ni_mgmt_nsg" {
  network_interface_id      = local.fgt_ni_ids["mgmt"]
  network_security_group_id = var.fgt_nsg_ids["mgmt"]
}
resource "azurerm_network_interface_security_group_association" "ni_public_nsg" {
  network_interface_id      = local.fgt_ni_ids["public"]
  network_security_group_id = var.fgt_nsg_ids["public"]
}