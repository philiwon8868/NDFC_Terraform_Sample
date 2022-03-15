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
  # the target is a Nexus Dashboard Fabric Controller
  platform = "nd"
}

resource "dcnm_inventory" "initialize-A" {
  fabric_name   = "A"
  username      = "<Switch Admin ID>"
  password      = "<Switch Admin Password>"
  max_hops      = 0
  preserve_config = "false"
  auth_protocol = 0
  config_timeout = 60
  switch_config {
    ip   = "<VPC-BGW OOB IP>"
    role = "border_gateway"
  }
  switch_config {
    ip   = "<VPC-BGW OOB IP>"
    role = "border_gateway"
  }
}

resource "dcnm_inventory" "initialize-B" {
  fabric_name   = "B"
  username      = "<Switch Admin ID>"
  password      = "<Switch Admin Password>"
  max_hops      = 0
  preserve_config = "false"
  auth_protocol = 0
  config_timeout = 60
  switch_config {
    ip   = "<VPC-BGW OOB IP>"
    role = "border_gateway"
  }
  switch_config {
    ip   = "<VPC-BGW OOB IP>"
    role = "border_gateway"
  }
}

resource "dcnm_rest" "recalculate" {
  path    = "/rest/control/fabrics/Multi-Site-4BGWs/config-save"
  method  = "POST"
  payload = <<EOF
  {
  }
  EOF
  depends_on = [
     dcnm_inventory.initialize-B,
     dcnm_inventory.initialize-A,
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
