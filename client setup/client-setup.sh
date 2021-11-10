#!/bin/zsh
#Arch install

echo "please enter servers ip address: "
read SERVER_IP
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

##install wireguard tools and ws tunnel
sudo pacman -S jq curl git wireguard-tools

WS_SERVER_PATH=/usr/local/bin/wstunnel
wget https://github.com/erebe/wstunnel/releases/download/v4.0/wstunnel-x64-linux
sudo mv wstunnel-x64-linux $WS_SERVER_PATH
sudo chmod uo+x $WS_SERVER_PATH

#wstunnel
#original script from : git@github.com:jnsgruk/wireguard-over-wss.git
sudo cp ./wstunnel-script.sh /etc/wireguard/wstunnel-script.sh
sudo chmod +x /etc/wireguard/wstunnel-script.sh

cat << EOF > ./client.wstunnel
REMOTE_HOST=$SERVER_IP
REMOTE_PORT=$WG_PORT
EOF
sudo mv ./client.wstunnel /etc/wireguard/$CLIENT_CONNECTION_NAME.wstunnel




