#!/bin/bash


# install Node.js
wget https://raw.githubusercontent.com/creationix/nvm/master/install.sh
chmod +x install.sh
./install.sh
rm -f install.sh
source ~/.bashrc
nvm install --lts

# install git
yum install -y git

# install freeipa-client
yum install -y freeipa-client

# install postgresql server
dnf install -y postgresql postgresql-server

# install backstage
npm config set strict-ssl=false
export NODE_TLS_REJECT_UNAUTHORIZED=0
npm install --global yarn
yarn config set "strict-ssl" false -g
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org 
cat << EOF >> install.sh
#!/usr/bin/env bash
{
sleep 5
echo backstage
sleep 10
echo backstage
} | npx @backstage/create-app@latest
EOF
chmod +x install.sh
./install.sh

rm -rf install.sh

cd backstage

# Add LDAP support
yarn add --cwd packages/backend @backstage/plugin-catalog-backend-module-ldap

# Add GitLab support
yarn add --cwd packages/backend @backstage/plugin-catalog-backend-module-gitlab

# open the firewall
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --permanent --add-port 3000/tcp
firewall-cmd --permanent --add-port 7007/tcp
firewall-cmd --reload
