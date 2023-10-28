output "fgts_zone_1" {
  value = {
    admin              = local.admin_username
    pass               = local.admin_password
    mgmt_public_ips    = module.fgt_zone_1.*.fgt_mgmt_public_ip
    service_public_ips = module.fgt_zone_1.*.fgt_public_ip
  }
}

output "fgts_zone_2" {
  value = {
    admin              = local.admin_username
    pass               = local.admin_password
    mgmt_public_ips    = module.fgt_zone_2.*.fgt_mgmt_public_ip
    service_public_ips = module.fgt_zone_2.*.fgt_public_ip
  }
}