#!/usr/bin/env bash
# Copyright (c) 2019 Romain Bruckert
# https://kvz.io/blog/2013/11/21/bash-best-practices/

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

env="$1"
appDistDir=${remoteDir}/${appDir}

if [ ! -d "${distDir}" ]
then
    echo -e "${red}✗ Build dir does not exist at ${distDir}${nc}"
    exit 1
fi

# do a full build (public build BEFORE server build)
# echo -e "${gray}♨ Building app for production (npm run build)${nc}"
# npm run build
#cp ./pm2.yml ./dist/pm2.yml
#cp ./package.json ./dist/package.json
#cp ./package-lock.json ./dist/package-lock.json

# create remote directory if it does not exist
echo -e "${gray}♨ Checking remote project directories${nc}"
ssh -t ${usrName}@${ip} "test -d ${appDistDir} || mkdir -p ${appDistDir}"
echo -e "${green}✔ Ok.${nc}"

echo -e "${gray}♨ Uploading files${nc}"
echo -e "${gray}♨ Excluding ${excludeDirs}${nc}"
rsync -avzP --no-perms --no-owner --no-group --delete --exclude node_modules/ ${excludeDirs} ${distDir}/* ${usrName}@${ip}:${appDistDir} > /dev/null 2>&1

# Info: if "cb() never called" error encountered
# http://www.alex-arriaga.com/issue-when-running-npm-install-npm-err-cb-never-called-solved/
if [ "${npmInstall}" = 1 ] ; then
    echo -e "${gray}♨ Running npm install${nc}"
    ssh -t ${usrName}@${ip} "cd ${appDistDir} && npm install --production"
fi

#echo $pm2
if [ "${pm2}" = 1 ] ; then
    echo "${pm2clusters}"
    echo -e "${gray}♨ Restarting PM2 processes with pm2.yml${nc}"
    ssh -t ${usrName}@${ip} "cd ${appDistDir} && pm2 kill && pm2 start index.js --name=${pm2appname} -i ${pm2clusters} -- --env=${env}"
fi

if [ ! -z "${postDeploy}" ]
then
    echo -e "${gray}♨ Executing post deploy script${nc}"
    ssh -t ${usrName}@${ip} "eval ${postDeploy}"
fi

echo -e "${green}✔ Ready.${nc}"
# echo ""
