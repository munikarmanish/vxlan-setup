#!/bin/bash

netns=kfc             # network namespace for tenant
br="$netns-br0"       # name for bridge device
vx="$netns-vxlan0"    # name for vxlan device

set -x

sudo ip netns delete $netns
sudo ip link delete $br
sudo ip link delete $vx

set +x
