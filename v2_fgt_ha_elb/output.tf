output "fgts_zone_1" {
  value = {
    admin            = local.admin_username
    pass             = local.admin_password
    fgt_1_mgmt_ip    = module.fgt_zone_1.*.fgt_1_mgmt_public_ip
    fgt_2_mgmt_ip    = module.fgt_zone_1.*.fgt_2_mgmt_public_ip
  }
}

output "fgts_zone_2" {
  value = {
    admin            = local.admin_username
    pass             = local.admin_password
    fgt_1_mgmt_ip    = module.fgt_zone_2.*.fgt_1_mgmt_public_ip
    fgt_2_mgmt_ip    = module.fgt_zone_2.*.fgt_2_mgmt_public_ip
  }
}

output "elb_zone_1" {
  value = module.elb_zone_1.*.elb_public-ip
}

output "elb_zone_2" {
  value = module.elb_zone_2.*.elb_public-ip
}