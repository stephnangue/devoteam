#!/bin/bash

# install git
sudo yum install -y git

# install freeipa-client
sudo yum install -y freeipa-client

# install postgresql server
sudo yum install -y postgresql postgresql-server
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

# install Node.js v18
curl -sL https://rpm.nodesource.com/setup_18.x | sudo -E bash -
sudo yum install -y nodejs

# install yarn
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo yum install -y -y yarn

# install backstage
npm config set strict-ssl=false
export NODE_TLS_REJECT_UNAUTHORIZED=0
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
yarn workspace backend add @immobiliarelabs/backstage-plugin-ldap-auth-backend
yarn workspace app add @immobiliarelabs/backstage-plugin-ldap-auth

# Add GitLab support
yarn add --cwd packages/backend @backstage/plugin-catalog-backend-module-gitlab

# Install PostgreSQL plugin
yarn add --cwd packages/backend pg

# Install SQLite 2 plugin
yarn add --cwd packages/backend better-sqlite3

# open the firewall
sudo firewall-cmd --zone=public --permanent --add-service=http
sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --permanent --add-port 3000/tcp
sudo firewall-cmd --permanent --add-port 7007/tcp
sudo firewall-cmd --reload

