# About
This Project aims to provide automated shell scripts in order to make it easy to setup a wireguard protected with secure websocket tunnel.

wireguard is a good vpn protocol which is easy to setup, connection reliable, few over-headed vpn protocol.
but in some places it cannot be used because of filtering.
this project want to scaffold the wireguard connection with an https (web-socket) tunnel.
it uses TLS1.3 and passes the packet inspections.

# Contribution
please feel free to improve codes & add shell script for other servers (like centos)

existing scripts are for:
* Server
    * Ubuntu 20
* Client & Administrator
    * Arch 

# How to Run

## Machines

* **The vpn server machine** : the vpn server, which has a public ip address and serves vpn, wss, dns services.
* **The administrator machine** : a machine who has access to vpn server machine via ssh. it will be use to define any new client.
* **client machines** : any machine who uses vpn services

## Setup Steps

* First you can run the scripts from the `server setup` directory on **the vpn server machine**, to setup the server
* then you can add any client, you want with the help of [create client](https://github.com/abilogos/wireguard-wss-full-setup/blob/main/create%20client/create-client-node.sh) scripts from **the administrator machine**
* for any of your **client machines**, they can use the [client setup/client-setup.sh](https://github.com/abilogos/wireguard-wss-full-setup/blob/main/client%20setup/client-setup.sh) script to setup their machine.
* clients can access to vpn services with the `vpn-up` & `vpn-down` commands on their machines.
