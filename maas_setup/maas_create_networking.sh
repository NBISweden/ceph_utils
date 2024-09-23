#!/bin/bash

# Define the MAAS profile
MAAS_PROFILE="ceph"

# Function to check if a fabric exists, if not, create it
create_fabric() {
    local fabric_name="$1"
    local fabric_id
    # Check if fabric already exists
    fabric_id=$(maas $MAAS_PROFILE fabrics read -k | jq -r --arg name "$fabric_name" '.[] | select(.name==$name) | .id')

    if [ -z "$fabric_id" ]; then
      echo "Creating fabric: $fabric_name"
      maas $MAAS_PROFILE fabrics create -k name="$fabric_name"
    else
      echo "Fabric '$fabric_name' already exists with id: $fabric_id"
    fi
}

# Function to create VLAN
create_vlan() {
    local fabric_name="$1"
    local vlan_vid="$2"
    local vlan_name="$3"
    local mtu="$4"
    local dhcp_on="$5"
    local primary_rack="$6"
    local fabric_id
    
    # Get the fabric ID
    fabric_id=$(maas $MAAS_PROFILE fabrics read -k | jq -r --arg name "$fabric_name" '.[] | select(.name==$name) | .id')

    # Check if VLAN exists
    vlan_id=$(maas $MAAS_PROFILE vlans read -k $fabric_id | jq -r --arg vid "$vlan_vid" '.[] | select(.vid==($vid|tonumber)) | .id')

    if [ -z "$vlan_id" ]; then
        echo "Creating VLAN (vid: $vlan_vid) for fabric: $fabric_name"
        maas $MAAS_PROFILE vlans create -k fabric=$fabric_id vid=$vlan_vid name="$vlan_name" mtu=$mtu dhcp_on=$dhcp_on primary_rack="$primary_rack"
    else
        echo "VLAN '$vlan_name' (vid: $vlan_vid) already exists in fabric '$fabric_name'."
    fi
}

# Function to create Subnet
create_subnet() {
    local cidr="$1"
    local vlan_name="$2"
    local fabric_name="$3"
    local gateway_ip="$4"
    local dns_servers="$5"
    local allow_dns="$6"
    local allow_proxy="$7"
    local active_discovery="$8"

    local fabric_id=$(maas $MAAS_PROFILE fabrics read -k | jq -r --arg name "$fabric_name" '.[] | select(.name==$name) | .id')
    local vlan_id=$(maas $MAAS_PROFILE vlans read -k $fabric_id | jq -r --arg name "$vlan_name" '.[] | select(.name==$name) | .id')

    # Check if subnet exists
    subnet_id=$(maas $MAAS_PROFILE subnets read -k | jq -r --arg cidr "$cidr" '.[] | select(.cidr==$cidr) | .id')
    
    if [ -z "$subnet_id" ]; then
        echo "Creating subnet: $cidr"
        maas $MAAS_PROFILE subnets create -k cidr="$cidr" gateway_ip="$gateway_ip" vlan=$vlan_id dns_servers="$dns_servers" allow_dns=$allow_dns allow_proxy=$allow_proxy active_discovery=$active_discovery
    else
        echo "Subnet $cidr already exists."
    fi
}

# Create fabrics
create_fabric "fabric-0"
create_fabric "external-network"
create_fabric "provisioning-network"
create_fabric "internal-ceph-network"

# VLANs creation for each fabric
create_vlan "fabric-0" 0 "untagged" 1500 false ""
create_vlan "external-network" 0 "untagged" 1500 false ""
create_vlan "provisioning-network" 0 "untagged" 1500 true "mhwshn" # with DHCP enabled
create_vlan "internal-ceph-network" 0 "untagged" 1500 false ""

# Subnets creation for each VLAN
create_subnet "172.17.0.0/16" "untagged" "fabric-0" "" "" true true false
create_subnet "10.10.11.0/24" "untagged" "internal-ceph-network" "" "" true true false
create_subnet "130.238.54.0/24" "untagged" "external-network" "130.238.54.129" "8.8.8.8" true true false
create_subnet "10.10.10.0/24" "untagged" "provisioning-network" "" "8.8.8.8" true true true # with active discovery

