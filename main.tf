
  resource "oci_core_virtual_network" "training_vcn" {
    cidr_block     = "10.0.0.0/16"
    dns_label      = "vcn1"
    compartment_id = "${var.compartment_ocid}"
    display_name   = "simple-vcn-terraform"
  }

  resource "oci_core_internet_gateway" "training_igw" {
    #Required
    compartment_id = "${var.compartment_ocid}"
    vcn_id         = "${oci_core_virtual_network.training_vcn.id}"

    #Optional
    display_name = "training-igw"
  }

  resource "oci_core_route_table" "training_rt" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id         = "${oci_core_virtual_network.training_vcn.id}"
    display_name   = "training_rt"

    route_rules {
      destination       = "0.0.0.0/0"
      network_entity_id = "${oci_core_internet_gateway.training_igw.id}"
    }
  }

  resource "oci_core_security_list" "training_sl" {
    compartment_id = "${var.compartment_ocid}"
    vcn_id         = "${oci_core_virtual_network.training_vcn.id}"
    display_name   = "training_sl"
    egress_security_rules = [
      { destination = "0.0.0.0/0" protocol = "all" }
    ]

    ingress_security_rules = [
      { protocol = "6", source = "0.0.0.0/0", tcp_options { "max" = 22, "min" = 22 }},
      { protocol = "6", source = "0.0.0.0/0", tcp_options { "max" = 80, "min" = 80 }}
    ]
  }

  resource "oci_core_subnet" "training_sn" {
    #Required
    compartment_id      = "${var.compartment_ocid}"
    vcn_id              = "${oci_core_virtual_network.training_vcn.id}"
    availability_domain = "${local.ad_1_name}"
    cidr_block          = "10.0.1.0/24"
    route_table_id      = "${oci_core_route_table.training_rt.id}"
    security_list_ids   = ["${oci_core_security_list.training_sl.id}"]


    #Optional
    display_name   = "training_sn"
  }

 #-------------------------ADW-------------------------------
 resource "random_string" "adw_admin_password" {
   length = 16
   special = true
 }

 resource "oci_database_autonomous_data_warehouse" "adw" {
   admin_password             = "${random_string.adw_admin_password.result}"
   compartment_id             = "${var.compartment_ocid}"
   cpu_core_count             = "${var.adw_cpu_count}"
   data_storage_size_in_tbs   = "${var.adw_data_storage_size_in_tb}"
   db_name                    = "${var.adw_db_name}"
   db_name                    = "sepp"
 }

data "oci_database_autonomous_data_warehouses" "adws" {
  compartment_id = "${var.compartment_ocid}"
}

 output "adw_admin_password" {
   value = "${random_string.adw_admin_password.result}"
 }

 /*
 output "autonomous_data_warehouses" {
   value = "${data.oci_database_autonomous_data_warehouses.adws.autonomnous_data_warehouses}"
 }
*/
 output "parallel_connection_string" {
   value = ["${lookup(oci_database_autonomous_data_warehouse.adw.connection_strings.0.all_connection_strings, "PARALLEL", "Unavailable")}"]
 }