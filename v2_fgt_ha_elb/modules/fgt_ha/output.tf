output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value = var.admin_password
}

output "fgt_1_id" {
  value = azurerm_virtual_machine.fgt_1.id
}

output "fgt_2_id" {
  value = azurerm_virtual_machine.fgt_1.id
}

output "fgt_1_mgmt_public_ip" {
  value = azurerm_public_ip.fgt_1_ni_mgmt.ip_address
}

output "fgt_2_mgmt_public_ip" {
  value = azurerm_public_ip.fgt_2_ni_mgmt.ip_address
}
