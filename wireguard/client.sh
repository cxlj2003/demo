ip link add dev wg0 type wireguard
wg setconf wg0 yisu.conf
ip link set wg0 up