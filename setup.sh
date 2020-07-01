#!/bin/bash

## load the config variables
source config.sh

set -x

## Create the bridge and vxlan interface
sudo ip link add $vx type vxlan id $vni group $group dstport $port dev $nic
sudo ip link add $br type bridge
sudo ip link set $vx master $br
sudo ip link set $vx up
sudo ip link set $br up

## Create the virtual interface connected to the overlay network
sudo ip netns add $ns

# VxLAN adds 50 bytes of headers, so MTU has to be adjusted
sudo ip link add $veth mtu 1450 type veth peer name $vethp mtu 1450
sudo ip link set $vethp master $br
sudo ip link set $veth netns $ns
sudo ip netns exec $ns ip addr add $ip dev $veth
sudo ip netns exec $ns ip link set $veth up
sudo ip netns exec $ns ip link set lo up
sudo ip link set $vethp up

set +x
