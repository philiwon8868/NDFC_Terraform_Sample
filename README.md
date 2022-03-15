# NDFC_Terraform_Sample

This is an example on how to use [Terraform](https://www.terraform.io) and REST API to automate Cisco Nexus Dashboard Fabric Controller ([NDFC](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/prime-data-center-network-manager/nb-06-ndfc-ds-cte-en.html)) for provisioning VXLAN EVPN underlay and overlay.

This project is derived from a previous project: https://github.com/philiwon8868/terraform-aci. It is a working sample for those who would like to leverage on NDFC's Terraform integration to experience the power of "Infrastructure As Code".

In this example, a sample Cisco Modeling Labs 2 ([CML2](https://www.cisco.com/c/en/us/products/cloud-systems-management/modeling-labs/index.html)) lab environment is setup with 2 pairs of VPC Border Gateways (VPC-BGWs) interconnecting to simulate a multi-site EVPN fabric as shown below

Figure 1: Logical Diagram of the Multi-Site VXLAN EVPN
<img width="574" alt="image" src="https://user-images.githubusercontent.com/8743281/158382324-617b083e-99a7-4ada-a6c6-8583acbf5f16.png">

 
![image](https://user-images.githubusercontent.com/8743281/158382811-f16e00da-35b1-4751-b623-188783b1d58e.png)

Figure 2: Cisco Modeling Lab 2 Environment

## Assumptions

1. All 4 VPC-BGWs switches are preconfigured with management IP addresses and can be reached by the NDFC OOB interface.
2. All 4 switches share the same admin user ID and password

## Requirements
Name | Version
---- | -------
[terraform](https://www.terraform.io/downloads.html)| >= 0.13
[NDFC](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/prime-data-center-network-manager/nb-06-ndfc-ds-cte-en.html)| >= 12.0.2f

## Providers
Name | Version
---- | -------
NDFC | >= 1.2.0

## Use Case Description

This example will deploy EVPN underlay configuration and the sample overlay network in 2 separate flows:

### EVPN Underlay  
#### Step 1: Switch Disovery & Switch Role Assignment
The main.tf in subdirectory **Underlay** will perform the switch discovery of the 4 Nexus 9000v and assign them the role of "Border Gateway" with **"preserve config"** set to **false**. Depending on CML2 environment, this step may take up to more than 30 minutes to complete.

Figure 3. Switches are added and being rebooted
![image](https://user-images.githubusercontent.com/8743281/158391516-f848d2db-8ee6-4227-ae26-023bc517c2b0.png)

#### Step 2: Go to the NDFC UI to perform vpc pairing for these 2 pairs of Border Gateway
In next release, this step will be removed with automation.

Figure 4. vPC pairing the 2 pairs of Border Gateway switches
![image](https://user-images.githubusercontent.com/8743281/158410253-faa0e0a8-e2f1-445d-86d0-70a202c9455c.png)

#### Step 3: Run the Python Recalculate.py to recalculate and deploy the configuration to the 4 switches
python3 Recalculate.py <name of the Multi-Site fabric> 

### Sample Overlay
The main.tf in subdirectory **Overaly-sample** will perform 3 actions:
1. Change the interface Ethernet1/4 of all 4 BGWs to switchport mode access
 ![image](https://user-images.githubusercontent.com/8743281/158412849-2b4b1a39-dd3c-4fc0-b432-e81d9d18ae17.png)

 Figure 5. Use REST API call in Terraform to make the interface change
 
2. Provision a VRF named "Tenant-B" and associate with all 4 BGWs; perform a recalculate-and-deploy to commit the change.
3. Provision a Network named "Web-Network" with an anycast gateway "192.168.1.1/24" and associate the Ethernet1/4 of switches A1 and B2 where 2 Ubuntu VMs are attached.

## Expected Result
Data traffic between the 2 Ubuntu VMs will flow through the overlay network provisioned.

Figure 6. Overlay network provisioned
![image](https://user-images.githubusercontent.com/8743281/158412220-1928bcb8-f11c-4eca-a08d-9dd9107c5a85.png)

## Usage

*To provision:*
 * Execute with usual *terraform init*, *terraform plan* and *terraform apply*

*To destroy:*
 * Destroy the deployment with *terraform destroy* command.

## Credits and references

1. [Cisco Infrastructure As Code](https://developer.cisco.com/iac/)
2. [DCNM provider Terraform](https://registry.terraform.io/providers/CiscoDevNet/dcnm/latest/docs#cisco-dcnm-provider)
3. [DCNM REST APIs](https://developer.cisco.com/docs/nexus-dashboard/#!nexus-dashboard-fabric-controller-lan-release-12-0-2)
