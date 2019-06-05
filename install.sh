#!/usr/bin/env bash
# Copyright (c) 2019 Romain Bruckert
# https://kvz.io/blog/2013/11/21/bash-best-practices/

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

env="$1"

echo -e "${gray}♨ Testing ip ${ip} for domain ${domain}${nc}"
ssh -oStrictHostKeyChecking=no -t root@${ip} "ls -1 | head -1"
echo -e "${green}✔ Ok.${nc}"

# echo -e "${red}♨ Removing unscd${nc}"
# https://www.digitalocean.com/community/questions/debian-9-3-droplet-issues-with-useradd
ssh -t root@${ip} "apt-get remove --purge -f unscd -y" > /dev/null 2>&1

###
# Update and create directories
##
if [ $aptUpgrade == 1 ]; then
    echo -e "${gray}♨ Upgrading debian and installing packages${nc}"
    ssh -t root@${ip} "apt-get update -y && apt-get upgrade -y && apt-get autoremove -y" > /dev/null 2>&1
    ssh -t root@${ip} "apt-get install nginx tree htop curl rsync software-properties-common -y" > /dev/null 2>&1
    echo -e "${green}✔ Ok.${nc}"
fi

###
# Create web user with sudo access and configure his SSH key
###
if ssh root@${ip} stat /home/paul/.ssh/authorized_keys \> /dev/null 2\>\&1; then
    echo -e "${brown}✔ User paul already exists, skipping${nc}"
else
    echo -e "${gray}♨ Creating user and configuring ssh keys${nc}"

    # quietly add a user without password
    ssh -t root@${ip} "adduser --quiet --disabled-password --shell /bin/bash --home /home/paul --gecos User paul"

    # set new user password
    echo "paul:mccartney" | ssh root@${ip} chpasswd

    # just in case home dir does not exist but it should
    ssh -t root@${ip} "mkdir -p /home/paul/.ssh"
    # add sudo privileges to user
    ssh -t root@${ip} "usermod -aG sudo paul"
    ssh -t root@${ip} "cp /root/.ssh/authorized_keys /home/paul/.ssh/authorized_keys"
    ssh -t root@${ip} "chown -R paul:paul /home/paul"

    echo -e "${gray}♨ Changing sudoers file for paul${nc}"
    ssh -t root@${ip} "echo 'paul    ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
    echo -e "${green}✔ Ok.${nc}"
fi

echo -e "${gray}♨ Creating project directories and ownership${nc}"
ssh -t root@${ip} "mkdir -p /home/srv/${appDir}" > /dev/null 2>&1
ssh -t root@${ip} "chown -R paul:paul /home/srv" > /dev/null 2>&1
echo -e "${green}✔ Ok.${nc}"

echo -e "${gray}♨ Installing Node.js${nc}"
ssh -t root@${ip} "sudo curl -sL https://deb.nodesource.com/setup_11.x | bash -" > /dev/null 2>&1
ssh -t root@${ip} "apt-get install -y nodejs" > /dev/null 2>&1
ssh -t root@${ip} "echo 'deb http://deb.debian.org/debian stretch-backports main' >> /etc/apt/sources.list" > /dev/null 2>&1
ssh -t root@${ip} "apt-get update -y && apt-get upgrade -y" > /dev/null 2>&1
echo -e "${green}✔ Ok.${nc}"

echo -e "${gray}♨ Installing certbot${nc}"
ssh -t root@${ip} "apt-get install certbot -t stretch-backports -y" > /dev/null 2>&1
echo -e "${brown}♨ You NEED TO Point a DNS A-recordfor ${domain} to ${ip} at this point. Did you? (y/N)${nc}"
read okAndWhatever

ssh -t root@${ip} "service nginx stop"
ssh -t root@${ip} "certbot certonly --standalone --agree-tos --preferred-challenges http -n -d ${domain} -m romain@360medics.com" > /dev/null 2>&1
ssh -t root@${ip} "chmod 755 /etc/letsencrypt/live/" > /dev/null 2>&1
ssh -t root@${ip} "chmod 755 /etc/letsencrypt/archive/" > /dev/null 2>&1
ssh -t root@${ip} "service nginx stop"
echo -e "${green}✔ Ok.${nc}"

echo -e "${gray}♨ Installing PM2${nc}"
ssh -t root@${ip} "npm install pm2 -g"
echo -e "${green}✔ Ok.${nc}"

echo -e "${green}✔ Point a DNS record (A) for ${domain} to ${appDir}${nc}"
echo -e "${green}✔ Ready.${nc}"
echo ""

exit 0
