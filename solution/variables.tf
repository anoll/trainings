variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "adw_cpu_count"                { default = 1 }
variable "adw_data_storage_size_in_tb"  { default = 1 }
variable "adw_db_name"                  { default = "cn_training_adw" }
variable "adw_licence_model"            { default = "LICENCE_INCLUDED" }
variable "adw_state"                    { default = "available" }
variable "adw_backup_display_name"      { default = "Monthly Backup" }
variable "adw_backup_state"             { default = "AVAILABLE" }


data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.tenancy_ocid}"
}
locals {
  ad_1_name = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")}"
  ad_2_name = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[1],"name")}"
  ad_3_name = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[2],"name")}"
}

data "oci_core_images" "training_images" {
  compartment_id    = "${var.compartment_ocid}"
  operating_system  = "CentOS"
}


locals {
  oracle_linux = "${lookup(data.oci_core_images.training_images.images[0], "id")}"
}