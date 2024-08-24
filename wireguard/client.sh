ip link add dev wg0 type wireguard
ip address add dev wg0 
wg setconf wg0 yisu.conf
ip link set wg0 up