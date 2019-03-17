variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

provider "oci" {
  version          = ">= 3.0.0"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

  resource "random_string" "adw_admin_password" {
    length = 16
    special = true
  }

resource "oci_database_autonomous_data_warehouse" "adw" {
  admin_password             = "${random_string.adw_admin_password.result}"
  compartment_id             = "${var.compartment_ocid}"
  cpu_core_count             = "${var.adw_cpu_count}"
  data_storage_size_in_tbs   = "${var.adw_data_storage_size_in_tb}"
  db_name                    = "AlbertsADW"
}


  output "adw_admin_password" {
    value = "${random_string.adw_admin_password.result}"
  }


