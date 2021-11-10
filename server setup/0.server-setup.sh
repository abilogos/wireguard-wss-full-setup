#!/bin/bash
#Server setup
echo "This bash script is for setting up ubuntu 20.0.4 server"
passwd

apt update
apt upgrade -y

function check_kernel_for_wireguard(){
    major=$(uname -r | cut -d '.' -f 1)
    minor=$(uname -r | cut -d '.' -f 2)
 if (( $major < 4 || (($major == 5 && $minor < 6)) )) || [[ $(uname -r) != *generic* ]]
 then
    apt install linux-modules-5.11.0-22-generic -y
 fi
}

read -e -p "want to install wireguard?" install_wireguard
if [[ $install_wireguard == [Yy]* ]]
then
    check_kernel_for_wireguard
fi

#setup ufw
ufw allow 22/tcp
ufw allow 53

# change ssh port
read -e -p "choose ssh port?(1-65535)[31337]" SSH_PORT
if ! [[ $SSH_PORT == [0-9]* ]]
then
    SSH_PORT=31337
fi
ufw allow $SSH_PORT/tcp
sed -i'.backup' 's/^\(Port \).*/\1'$SSH_PORT'/' /etc/ssh/sshd_config

echo 'you can add your public key to server like below'
echo 'first generate your public & private key using openssl'
echo 'ssh-copy-id -i ~/.ssh/id_rsa.pub -p $SSH_PORT root@<server address>    ok?'
read ok
echo "because of kernel update we need to reboot the server"
ufw enable
systemctl enable --now ufw.service
#restart for os and kernel upgrade and ssh change port
reboot
