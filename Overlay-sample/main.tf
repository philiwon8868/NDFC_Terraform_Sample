terraform {
  required_providers {
    dcnm = {
      source = "CiscoDevNet/dcnm"
    }
  }
}

#configure provider with your cisco dcnm/ndfc credentials.
provider "dcnm" {

  # cisco-dcnm/ndfc user name
  username = "<user name>"
  # cisco-dcnm/ndfc password
  password = "<password>"
  # cisco-dcnm/ndfc url
  url      = "https://<ip of the NDFC>"
  insecure = true
  platform = "nd"
}

data "dcnm_inventory" "A1" {
  fabric_name = "Multi-Site-4BGWs"
  switch_name = "nxos9000-A-1"
}

data "dcnm_inventory" "A2" {
  fabric_name = "Multi-Site-4BGWs"
  switch_name = "nxos9000-A-2"
}

data "dcnm_inventory" "B1" {
  fabric_name = "Multi-Site-4BGWs"
  switch_name = "nxos9000-B-1"
}

data "dcnm_inventory" "B2" {
  fabric_name = "Multi-Site-4BGWs"
  switch_name = "nxos9000-B-2"
}

resource "dcnm_vrf" "Tenant-B" {
  fabric_name = "Multi-Site-4BGWs"
  name = "Tenant-B"
  description = "This VRF is created by terraform"
  deploy = "true"
  attachments {
    serial_number = "${data.dcnm_inventory.A1.serial_number}"
  }
  attachments {
    serial_number = "${data.dcnm_inventory.A2.serial_number}"
  }
  attachments {
    serial_number = "${data.dcnm_inventory.B1.serial_number}"
  }
  attachments {
    serial_number = "${data.dcnm_inventory.B2.serial_number}"
  }
}

resource "dcnm_rest" "change_port_A1_e1_4" {
  path    = "/rest/interface"
  method  = "PUT"
  payload_type = "json"
  payload = <<EOF
  {
    "policy": "int_access_host",
    "interfaces": [
      {
        "serialNumber": "${data.dcnm_inventory.A1.serial_number}",
        "ifName": "Ethernet1/4",
        "nvPairs": {
            "CONF": "",
            "ACCESS_VLAN" : "",
            "DESC" : "Modified by Python",
            "INTF_NAME": "Ethernet1/4",
            "MTU": "jumbo",
            "SPEED": "Auto",
            "ADMIN_STATE": "true",
            "PORTTYPE_FAST_ENABLED": "true",
            "BPDUGUARD_ENABLED": "true"
            }
      }
    ]
  }
  EOF
}

resource "dcnm_rest" "change_port_A2_e1_4" {
  path    = "/rest/interface"
  method  = "PUT"
  payload = <<EOF
  {
    "policy": "int_access_host",
    "interfaces": [
      {
        "serialNumber": "${data.dcnm_inventory.A2.serial_number}",
        "ifName": "Ethernet1/4",
        "nvPairs": {
            "CONF": "",
            "ACCESS_VLAN" : "",
            "DESC" : "Modified by Python",
            "INTF_NAME": "Ethernet1/4",
            "MTU": "jumbo",
            "SPEED": "Auto",
            "ADMIN_STATE": "true",
            "PORTTYPE_FAST_ENABLED": "true",
            "BPDUGUARD_ENABLED": "true"
            }
      }
    ]
  }
  EOF
}

resource "dcnm_rest" "change_port_B1_e1_4" {
  path    = "/rest/interface"
  method  = "PUT"
  payload = <<EOF
  {
    "policy": "int_access_host",
    "interfaces": [
      {
        "serialNumber": "${data.dcnm_inventory.B1.serial_number}",
        "ifName": "Ethernet1/4",
        "nvPairs": {
            "CONF": "",
            "ACCESS_VLAN" : "",
            "DESC" : "Modified by Python",
            "INTF_NAME": "Ethernet1/4",
            "MTU": "jumbo",
            "SPEED": "Auto",
            "ADMIN_STATE": "true",
            "PORTTYPE_FAST_ENABLED": "true",
            "BPDUGUARD_ENABLED": "true"
            }
      }
    ]
  }
  EOF
}

resource "dcnm_rest" "change_port_B2_e1_4" {
  path    = "/rest/interface"
  method  = "PUT"
  payload = <<EOF
  {
    "policy": "int_access_host",
    "interfaces": [
      {
        "serialNumber": "${data.dcnm_inventory.B2.serial_number}",
        "ifName": "Ethernet1/4",
        "nvPairs": {
            "CONF": "",
            "ACCESS_VLAN" : "",
            "DESC" : "Modified by Python",
            "INTF_NAME": "Ethernet1/4",
            "MTU": "jumbo",
            "SPEED": "Auto",
            "ADMIN_STATE": "true",
            "PORTTYPE_FAST_ENABLED": "true",
            "BPDUGUARD_ENABLED": "true"
            }
      }
    ]
  }
  EOF
}

resource "dcnm_rest" "recalculate" {
  path    = "/rest/control/fabrics/Multi-Site-4BGWs/config-save"
  method  = "POST"
  payload = <<EOF
  {
  }
  EOF
  depends_on = [
        dcnm_rest.change_port_A1_e1_4,
        dcnm_rest.change_port_A2_e1_4,
        dcnm_rest.change_port_B1_e1_4,
        dcnm_rest.change_port_B2_e1_4,
  ]
}

resource "dcnm_rest" "deploy" {
  path    = "/rest/control/fabrics/Multi-Site-4BGWs/config-deploy"
  method  = "POST"
  payload = <<EOF
  {
  }
  EOF
  depends_on = [
     dcnm_rest.recalculate,
  ]
}
resource "dcnm_network" "Web-Network" {
  fabric_name     = "Multi-Site-4BGWs"
  name            = "Web-Network"
  display_name    = "Web-Network"
  description     = "Overlay network named Web-Network created by Terraform"
  vrf_name        = "Tenant-B"
  ipv4_gateway    = "192.168.1.1/24"
  l3_gateway_flag = true
  deploy = true
  attachments {
    serial_number = "${data.dcnm_inventory.B2.serial_number}"
    switch_ports = ["Ethernet1/4"]
  }
  attachments {
    serial_number = "${data.dcnm_inventory.A1.serial_number}"
    switch_ports = ["Ethernet1/4"]
  }
  attachments {
    serial_number = "${data.dcnm_inventory.B1.serial_number}"
  }
  attachments {
    serial_number = "${data.dcnm_inventory.A2.serial_number}"
  }
  depends_on = [
     dcnm_rest.deploy,
  ]

}
