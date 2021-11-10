#!/bin/bash
# setup wireguard server + ip forwarding

echo "please enter servers wireguard port: (1-65535)[51820] "
read WG_PORT
if [ -z "$WG_PORT"  ]
then
    WG_PORT=51820
fi
echo "please provide server private network ipv4 address: (example 10.10.10.1)"
read SERVER_IP_4
echo "please provide private network ipv4 cidr: (8-32) [24]"
read NETWORK_CIDR_4
if [ -z "$NETWORK_CIDR_4"  ]
then
    NETWORK_CIDR_4=24
fi
echo "please provide server private network ipv6 address: (example fd4e:cd6e:5c0e::1)"
read SERVER_IP_6
echo "please provide private network ipv6 cidr: (48-128) [64]"
read NETWORK_CIDR_6
if [ -z "$NETWORK_CIDR_6"  ]
then
    NETWORK_CIDR_6=64
fi


apt install wireguard -y
WG_PRIVATE=$(wg genkey)
WG_PUBLIC=$(echo $WG_PRIVATE | wg pubkey | tee /etc/wireguard/wg0.pub)

NETWORK_DEVICE=$(ip r | grep default | grep -E -o 'dev \w*' | cut -d ' ' -f 2 )

ufw allow $WG_PORT/udp

cat << EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $WG_PRIVATE
Address = $SERVER_IP_4/$NETWORK_CIDR_4, $SERVER_IP_6/$NETWORK_CIDR_6
ListenPort = $WG_PORT
SaveConfig = true

PostUp = ufw route allow in on wg0 out on $NETWORK_DEVICE
PostUp = iptables -A FORWARD -i %i -j ACCEPT;
PostUp = iptables -A FORWARD -o %i -j ACCEPT;
PostUp = iptables -t nat -I POSTROUTING -o $NETWORK_DEVICE -j MASQUERADE

PostUp = ip6tables -A FORWARD -i %i -j ACCEPT;
PostUp = ip6tables -A FORWARD -o %i -j ACCEPT;
PostUp = ip6tables -t nat -I POSTROUTING -o $NETWORK_DEVICE -j MASQUERADE

PreDown = ufw route delete allow in on wg0 out on $NETWORK_DEVICE
PreDown = iptables -t nat -D POSTROUTING -o $NETWORK_DEVICE -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT;
PostDown = iptables -D FORWARD -o %i -j ACCEPT;

PreDown = ip6tables -t nat -D POSTROUTING -o $NETWORK_DEVICE -j MASQUERADE
PostDown = ip6tables -D FORWARD -i %i -j ACCEPT;
PostDown = ip6tables -D FORWARD -o %i -j ACCEPT;

EOF

systemctl enable --now wg-quick@wg0.service
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf
sysctl -p
#TODO: find a way to no-need for reboot for activating ip6 forwarding:
#echo 1 > /proc/sys/net/ipv4/ip_forward
reboot
