output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value = var.admin_password
}

output "fgt_id" {
  value = azurerm_virtual_machine.fgt.id
}

output "fgt_mgmt_public_ip" {
  value = azurerm_public_ip.ni_mgmt.ip_address
}

output "fgt_public_ip" {
  value = azurerm_public_ip.ni_public.ip_address
}

