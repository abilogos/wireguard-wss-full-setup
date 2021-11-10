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
* Client
    * Arch 

# How to Run

* First you can run the scripts from `server setup` directory on your server, to setup the server
* then you can add a client with help of `create client` scripts from your server
* after that for your client machine you can use the `client setup/client-setup.sh` script
