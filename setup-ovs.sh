#!/bin/bash

ns_="ns0"
vni_=123
vx_="vxlan$vni_"
br_="br$vni_"
veth_="veth0"
port_=4789
remote_ip_=192.168.0.8
ip_=10.0.1.2/24

set -x

## create bridge and vtep
sudo ovs-vsctl add-br $br_
sudo ovs-vsctl add-port $br_ $vx_ -- set interface $vx_ type=vxlan \
    options:key=$vni_ options:remote_ip=$remote_ip_ options:dst_port=$port_

## create node
sudo ip netns add $ns_

sudo ovs-vsctl add-port $br_ $veth_ -- set interface $veth_ type=internal
sudo ip link set $veth_ netns $ns_
sudo ip netns exec $ns_ ip addr add $ip_ dev $veth_
sudo ip netns exec $ns_ ip link set veth0 mtu 1450
sudo ip netns exec $ns_ ip link set veth0 up
sudo ip netns exec $ns_ ip link set lo up

set +x
