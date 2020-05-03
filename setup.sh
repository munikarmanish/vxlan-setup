#!/bin/bash

nic=eno1              # name of physical interface
netns=kfc             # network namespace for tenant
ip=10.0.0.1/24        # private ip for the tenant network interface
vni=123               # vxlan network id
group=224.0.0.1       # vxlan multicast group ip
br="$netns-br0"       # name for bridge device
vx="$netns-vxlan0"    # name for vxlan device
eth0="$netns-eth0"    # name for veth interface in tenant namespace
eth0p="$netns-eth0p"  # name for veth interface in host namespace

set -x

# add a namespace
sudo ip netns add $netns

# add a bridge
sudo ip link add $br type bridge

# add a vxlan device and attach to bridge
sudo ip link add $vx type vxlan id $vni dev $nic group $group dstport 0
sudo ip link set $vx master $br

# add veth pairs
sudo ip link add $eth0 type veth peer name $eth0p
sudo ip link set $eth0 netns $netns
sudo ip link set $eth0p master $br
sudo ip link set $eth0 mtu 1450   # 1500 - 50 (vxlan adds 50 bytes of header)
sudo ip link set $eth0p mtu 1450

# set the ip
sudo ip netns exec $netns ip addr add dev $eth0 $ip

# turn on them devices
sudo ip link set $br up
sudo ip link set $vx up
sudo ip link set $eth0p up
sudo ip netns exec $netns ip link set lo up
sudo ip netns exec $netns ip link set $eth0 up

set +x
