#!/bin/bash

set -x

## Create the bridge and vxlan interface

nic_="eno1"      # physical device name
vni_=123         # vxlan network id
vx_="vxlan$vni_"  # name of the vxlan interface
br_="br$vni_"     # name of overlay bridge
group_=239.1.1.1 # vxlan ip multicast address
port_=0          # vxlan port (0 = linux default, 4789 = standard default)

sudo ip link add $vx_ type vxlan id $vni_ group $group_ dstport $port_ dev $nic_
sudo ip link add $br_ type bridge
sudo ip link set $vx_ master $br_
sudo ip link set $vx_ up
sudo ip link set $br_ up

## Create the virtual interface connected to the overlay network

ns_="ns0"            # network namespace for the virtual interface
veth_="veth0"        # virtual interface name
vethp_="${veth_}p"    # virtual interface name for the peer
ip_=10.0.1.2/24      # ip address for virtual interface

sudo ip netns add $ns_

# VxLAN adds 50 bytes of headers, so MTU has to be adjusted
sudo ip link add $veth_ mtu 1450 type veth peer name $vethp_ mtu 1450
sudo ip link set $vethp_ master $br_
sudo ip link set $veth_ netns $ns_
sudo ip netns exec $ns_ ip addr add $ip_ dev $veth_
sudo ip netns exec $ns_ ip link set $veth_ up
sudo ip netns exec $ns_ ip link set lo up
sudo ip link set $vethp_ up

set +x
