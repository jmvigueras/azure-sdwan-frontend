output "vnet" {
  value = {
    name = azurerm_virtual_network.vnet-fgt.name
    id   = azurerm_virtual_network.vnet-fgt.id
  }
}

output "subnet_cidrs" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.address_prefixes[0]
    public  = azurerm_subnet.subnet-public.address_prefixes[0]
    private = azurerm_subnet.subnet-private.address_prefixes[0]
  }
}

output "subnet_names" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.name
    public  = azurerm_subnet.subnet-public.name
    private = azurerm_subnet.subnet-private.name
  }
}

output "subnet_ids" {
  value = {
    mgmt    = azurerm_subnet.subnet-hamgmt.id
    public  = azurerm_subnet.subnet-public.id
    private = azurerm_subnet.subnet-private.id
  }
}

output "nsg_ids" {
  value = {
    mgmt    = azurerm_network_security_group.nsg-mgmt-ha.id
    public  = azurerm_network_security_group.nsg-public.id
    private = azurerm_network_security_group.nsg-private.id
  }
}

