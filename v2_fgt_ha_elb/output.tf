output "fgt_clusters" {
  value = {
    admin         = local.admin_username
    pass          = local.admin_password
    fgt_1_mgmt_ip = module.fgt_clusters.*.fgt_1_mgmt_public_ip
    fgt_2_mgmt_ip = module.fgt_clusters.*.fgt_2_mgmt_public_ip
  }
}

output "elbs" {
  value = module.elbs.*.elb_public-ip
}
