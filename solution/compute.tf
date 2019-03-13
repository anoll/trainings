/*resource "oci_core_instance" "training_vm" {
  compartment_id        = "${var.compartment_ocid}"
  display_name          = "training-vm"
  availability_domain   = "${local.ad_1_name}"
  shape                 = "VM.Standard2.1"



  source_details {
    source_id     = "${local.oracle_linux}"
    source_type   = "image"
  }


  create_vnic_details {
    subnet_id         = "${oci_core_subnet.training_sn.id}"
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
}*/