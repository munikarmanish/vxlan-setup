#!/bin/bash

create_vxlan_network() { # <vni>
    if (( $# < 1 )); then
        echo " :: ERROR :: $0 :: bad argument"
        return 1
    fi

    vni="$1"
    vx="vxlan$vni"
    br="br$vni"
    port="${2:-4789}"
    group="239.1.1.$vni"
    nic="enp94s0"

    ## Create the bridge and vxlan interface
    sudo ip link add $vx type vxlan id $vni group $group dstport $port dev $nic
    sudo ip link add $br type bridge
    sudo ip link set $vx master $br
    sudo ip link set $vx up
    sudo ip link set $br up
}

delete_vxlan_network() { # <vni>
    if (( $# != 1 )); then
        echo " :: ERROR :: $0 :: bad argument"
        return 1
    fi

    vni="$1"
    vx="vxlan$vni"
    br="br$vni"

    sudo ip link delete $br
    sudo ip link delete $vx
}

create_container() { # <id> <vni>
    if (( $# != 2 )); then
        echo " :: ERROR :: $0 :: bad argument"
        return 1
    fi

    id="$1"
    ip="10.0.1.$id/24"
    ns="ns$id"
    veth="veth$id"
    vethp="${veth}p"

    vni="$2"
    br="br$vni"

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
}

delete_container() { # <id>
    if (( $# != 1 )); then
        echo " :: ERROR :: $0 :: bad argument"
        return 1
    fi

    id="$1"
    ns="ns$id"
    veth="veth$id"
    vethp="${veth}p"

    sudo ip link delete $vethp
    sudo ip netns del $ns
}

create_containers() { # <start_id> <end_id> <vni>
    if (( $# != 3 )); then
        echo " :: ERROR :: $0 :: bad argument"
        return 1
    fi

    beg_id="$1"
    end_id="$2"
    vni="$3"

    for id in $(seq $beg_id $end_id); do
        create_container $id $vni
    done
}

delete_containers() { # <start_id> <end_id>
    if (( $# != 2 )); then
        echo " :: ERROR :: $0 :: bad argument"
        return 1
    fi

    beg_id="$1"
    end_id="$2"

    for id in $(seq $beg_id $end_id); do
        delete_container $id
    done
}

nsrun() { # <id> <command...>
    if (( $# < 2 )); then
        echo " :: ERROR :: $0 :: bad argument"
        return 1
    fi

    ns="ns$1"
    shift
    cmd="$@"

    sudo ip netns exec $ns $cmd
}

