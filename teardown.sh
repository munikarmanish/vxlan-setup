#!/bin/bash

source config.sh

set -x

sudo ip link delete $vethp
sudo ovs-vsctl del-port $vx
sudo ip link delete $vx
sudo ovs-vsctl del-br $br
sudo ip link delete $br
sudo ip netns del $ns

set +x
