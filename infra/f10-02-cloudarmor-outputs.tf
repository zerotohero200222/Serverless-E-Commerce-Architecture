##############################################################################
# f10-02-cloudarmor-outputs.tf — Cloud Armor outputs
##############################################################################

output "cloud_armor_policy_name" {
  description = "Name of the Cloud Armor security policy attached to the API backend."
  value       = google_compute_security_policy.armor.name
}

output "cloud_armor_policy_id" {
  description = "Self-link of the Cloud Armor security policy."
  value       = google_compute_security_policy.armor.self_link
}