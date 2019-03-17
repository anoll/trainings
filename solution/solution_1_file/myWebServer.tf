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

resource "oci_core_vcn" "Cloud_Native_Training_VCN" {
  cidr_block      = "10.0.0.0/16"
  compartment_id  = "${var.compartment_ocid}"

  display_name    = "Cloud Native Training VCN"
}

resource "oci_core_internet_gateway" "Cloud_Native_Training_VCN" {
  compartment_id  = "${var.compartment_ocid}"
  vcn_id          = "${oci_core_vcn.Cloud_Native_Training_VCN.id}"

  display_name    = "Cloud Native Training IGW"
}

resource "oci_core_route_table" "Cloud_Native_Training_RT" {
  compartment_id  = "${var.compartment_ocid}"
  vcn_id          = "${oci_core_vcn.Cloud_Native_Training_VCN.id}"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.Cloud_Native_Training_VCN.id}"
  }

  display_name    = "Cloud Native Training RT"
}

resource "oci_core_security_list" "Cloud_Native_Training_SL" {
  compartment_id  = "${var.compartment_ocid}"
  vcn_id          = "${oci_core_vcn.Cloud_Native_Training_VCN.id}"

  egress_security_rules = [
    { destination = "0.0.0.0/0" protocol = "all" }
  ]

  ingress_security_rules = [
    { protocol = "6", source = "0.0.0.0/0", tcp_options { "max" = 22, "min" = 22 }},
    { protocol = "6", source = "0.0.0.0/0", tcp_options { "max" = 80, "min" = 80 }}
  ]

  display_name   = "training_sl"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.tenancy_ocid}"
}

locals {
  ad_1 = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0], "name")}"
}


resource "oci_core_subnet" "Cloud_Native_Training_SN" {
  compartment_id    = "${var.compartment_ocid}"
  vcn_id            = "${oci_core_vcn.Cloud_Native_Training_VCN.id}"
  cidr_block        = "10.0.1.0/24"
  security_list_ids = ["${oci_core_security_list.Cloud_Native_Training_SL.id}"]
  route_table_id    = "${oci_core_route_table.Cloud_Native_Training_RT.id}"

  display_name    = "Cloud Native Training SN"
  availability_domain = "${local.ad_1}"

}

data "oci_core_images" "Cloud_Native_Training_Images" {
  compartment_id    = "${var.tenancy_ocid}"
  operating_system  = "Oracle Linux"
  shape             = "VM.Standard2.1"
}


locals {
  oracle_linux = "${lookup(data.oci_core_images.Cloud_Native_Training_Images.images[0],"id")}"
}

resource "oci_core_instance" "Cloud_Native_Training_VM" {
  compartment_id        = "${var.compartment_ocid}"
  availability_domain   = "${local.ad_1}"
  shape                 = "VM.Standard2.1"

  source_details {
    source_id     = "${local.oracle_linux}"
    source_type   = "image"
  }
  create_vnic_details {
    subnet_id         = "${oci_core_subnet.Cloud_Native_Training_SN.id}"
    display_name      = "primary_vnic"
    assign_public_ip  = true
  }
  metadata {
    ssh_authorized_keys = "${file("~/.ssh/id_rsa.pub")}"
    user_data           = "${base64encode(file("vm.cloud-config"))}"
  }
  timeouts {
    create = "5m"
  }

  display_name          = "Cloud_Native_Training_VM"
}

  output "public_ip" {
    value = "${oci_core_instance.Cloud_Native_Training_VM.public_ip}"
  }