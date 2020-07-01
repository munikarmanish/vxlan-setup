#!/bin/bash

source config.sh

set -x

## create bridge and vtep
sudo ovs-vsctl add-br $br
sudo ovs-vsctl add-port $br $vx -- set interface $vx type=vxlan \
    options:key=$vni options:remoteip=$remoteip options:dstport=$port

## create node
sudo ip netns add $ns

sudo ovs-vsctl add-port $br $veth -- set interface $veth type=internal
sudo ip link set $veth netns $ns
sudo ip netns exec $ns ip addr add $ip dev $veth
sudo ip netns exec $ns ip link set veth0 mtu 1450
sudo ip netns exec $ns ip link set veth0 up
sudo ip netns exec $ns ip link set lo up

set +x
