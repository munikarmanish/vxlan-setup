# physical device name
nic="enp94s0"

# vxlan network id
vni=123

# name of the vxlan interface
vx="vxlan${vni}"

# name of overlay bridge
br="br${vni}"

# vxlan ip multicast address
group=239.1.1.1

# vxlan port (0 = linux default, 4789 = standard default)
port=4789

# network namespace for the virtual interface
ns="ns0"

# virtual interface name
veth="veth0"

# virtual interface name for the peer
vethp="${veth}p"

# ip address for virtual interface (also include the netmask)
ip=10.0.1.2/24

# ip address of the remote physical host (don't include the netmask)
remote_ip=192.168.1.2
