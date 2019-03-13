resource "random_string" "wallet_password" {
  length = 16
  special = true
}

data "oci_database_autonomous_data_warehouse_wallet" "adw_wallet" {
  autonomous_data_warehouse_id  = "${oci_database_autonomous_data_warehouse.adw.id}"
  password                      = "${random_string.wallet_password.result}"
}

resource "local_file" "adw_wallet_file" {
  content = "${data.oci_database_autonomous_data_warehouse_wallet.adw_wallet.content}"
  filename = "awd_wallet.zip"
}

output "wallet_password" {
  value = ["${random_string.wallet_password.result}"]
}