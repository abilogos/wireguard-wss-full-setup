#!/bin/zsh

echo "please enter servers ip address:"
read SERVER_IP
echo "please enter servers ssh port: (1-65535)[22] "
read SERVER_SSH_PORT
if [ -z "$SERVER_SSH_PORT"  ]
then
    SERVER_SSH_PORT=22
fi
echo "please enter servers wireguard port: (1-65535)[51820] "
read WG_PORT
if [ -z "$WG_PORT"  ]
then
    WG_PORT=51820
fi
echo "please provide client connection name: [client]"
read CLIENT_CONNECTION_NAME
if [ -z "$CLIENT_CONNECTION_NAME"  ]
then
    CLIENT_CONNECTION_NAME=client
fi
echo "please provide server connection name: [wg0]"
read SERVER_CONNECTION_NAME
if [ -z "$SERVER_CONNECTION_NAME"  ]
then
    SERVER_CONNECTION_NAME=wg0
fi
echo "please provide DNS SERVER (server) private network ipv4 address: (example 10.10.10.1)"
read NETWORK_DNS
echo "please provide client private network ipv4 address: (example 10.10.10.2)"
read CLIENT_IP_4
echo "please provide private network ipv4 cidr: (8-32) [24]"
read NETWORK_CIDR_4
if [ -z "$NETWORK_CIDR_4"  ]
then
    NETWORK_CIDR_4=24
fi
echo "please provide client private network ipv6 address: (example fd4e:cd6e:5c0e::2)"
read CLIENT_IP_6
echo "please provide private network ipv6 cidr: (48-128) [64]"
read NETWORK_CIDR_6
if [ -z "$NETWORK_CIDR_6"  ]
then
    NETWORK_CIDR_6=64
fi

echo "will be connect to server, hope you set the ssh keys on server ...\n"
SERVER_PUBLIC=$(ssh -p $SERVER_SSH_PORT root@$SERVER_IP "cat /etc/wireguard/$SERVER_CONNECTION_NAME.pub")


mkdir ./$CLIENT_CONNECTION_NAME
CL_PRIVATE=$(wg genkey)
CL_PUBLIC=$(echo $CL_PRIVATE | wg pubkey | tee ./$CLIENT_CONNECTION_NAME/$CLIENT_CONNECTION_NAME.pub)
CL_PSK=$(wg genpsk)

cat << EOF > ./$CLIENT_CONNECTION_NAME/$CLIENT_CONNECTION_NAME.conf
[Interface]

Address = $CLIENT_IP_4/$NETWORK_CIDR_4, $CLIENT_IP_6/$NETWORK_CIDR_6
DNS = $NETWORK_DNS
PrivateKey = $CL_PRIVATE

#for wss tunnel
Table = off
PreUp = source /etc/wireguard/wstunnel-script.sh && pre_up %i
PostUp = source /etc/wireguard/wstunnel-script.sh && post_up %i
PostDown = source /etc/wireguard/wstunnel-script.sh && post_down %i

[Peer]
PublicKey = $SERVER_PUBLIC
PresharedKey = $CL_PSK
AllowedIPs = 0.0.0.0/0, ::/0

#Endpoint = $SERVER_IP:$WG_PORT
#for wss tnnel
Endpoint=127.0.0.1:$WG_PORT
PersistentKeepalive = 25

EOF

ssh -p $SERVER_SSH_PORT root@$SERVER_IP "echo $CL_PSK >> /tmp/psk.key;wg set $SERVER_CONNECTION_NAME peer $CL_PUBLIC preshared-key /tmp/psk.key allowed-ips $CLIENT_IP_4/32,$CLIENT_IP_6/128;systemctl restart wg-quick@$SERVER_CONNECTION_NAME.service;rm /tmp/psk.key"
