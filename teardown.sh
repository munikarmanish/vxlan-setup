#!/bin/bash

set -x

sudo ip link delete $vethp_
sudo ovs-vsctl del-port $vx_
sudo ip link delete $vx_
sudo ovs-vsctl del-br $br_
sudo ip link delete $br_
sudo ip netns del $ns_

set +x
