#!/bin/bash
# setup wss server
echo "please enter servers wireguard port: (1-65535)[51820] "
read WG_PORT
if [ -z "$WG_PORT"  ]
then
    WG_PORT=51820
fi
echo "please enter servers wss port: (1-65535)[433] "
read WSS_PORT
if [ -z "$WSS_PORT"  ]
then
    WSS_PORT=433
fi

WS_SERVER_PATH=/usr/local/bin/wstunnel
wget https://github.com/erebe/wstunnel/releases/download/v4.0/wstunnel-x64-linux
mv wstunnel-x64-linux $WS_SERVER_PATH
chmod uo+x $WS_SERVER_PATH
setcap CAP_NET_BIND_SERVICE=+eip $WS_SERVER_PATH
cat << EOF >> /etc/systemd/system/wstunnel.service
[Unit]
Description=Tunnel Wireguard UDP Over WebSocket
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=$WS_SERVER_PATH -v --server wss://0.0.0.0:$WSS_PORT --restrictTo=127.0.0.1:$WG_PORT
Restart=always
RuntimeMaxSec=14400

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now wstunnel
ufw allow $WSS_PORT
