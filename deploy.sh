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

# create remote directory if it does not exist
echo -e "${gray}♨ Checking remote project directories${nc}"
ssh -t ${usrName}@${ip} "test -d ${appDistDir} || mkdir -p ${appDistDir}"
echo -e "${green}✔ Ok.${nc}"

echo -e "${gray}♨ Uploading files${nc}"
echo -e "${gray}♨ Excluding ${excludeDirs}${nc}"
rsync -avzP --no-perms --no-owner --no-group --delete --exclude node_modules/ ${excludeDirs} ${distDir}/* ${usrName}@${ip}:${appDistDir} > /dev/null 2>&1

# Info: if "cb() never called" error encountered
# http://www.alex-arriaga.com/issue-when-running-npm-install-npm-err-cb-never-called-solved/
if [ "${npmInstall}" = "1" ] ; then
    echo -e "${gray}♨ Running npm install${nc}"
    ssh -t ${usrName}@${ip} "cd ${appDistDir} && npm install --omit=dev" > /dev/null 2>&1
else
    echo -e "${gray}♨ Skipping npm install${nc}"
fi

#echo $pm2
if [ "${pm2}" = "1" ] ; then
    # check if pm2.ENV.yml file exists in remote project, if not, start pm2 process with defaults basic arguments
    REMOTE_PM2_FILE="${appDistDir}/pm2.${env}.yml"
    
    if ssh -t ${usrName}@${ip} "test -e ${REMOTE_PM2_FILE}"
    then
        # use pm2 yml as pm2 configuration
        echo -e "${gray}♨ Restarting PM2 processes (with ${REMOTE_PM2_FILE})${nc}"
        ssh -t ${usrName}@${ip} "cd ${appDistDir} && pm2 kill && pm2 start ${REMOTE_PM2_FILE}"
    else
        # use pm2 yml as pm2 configuration
        echo -e "${gray}♨ Restarting PM2 processes (default options)${nc}"
        echo -e "${red}♨ PM2 DEFAULT APP NAME NOT RECOMMENED IF MULTIPLE NODE APPS ARE RUNNING! ${nc}"
        ssh -t ${usrName}@${ip} "cd ${appDistDir} && pm2 kill && pm2 start index.js --name=${pm2appname} -i ${pm2clusters} -- --env=${env}"
    fi
else
    echo -e "${gray}♨ Skipping PM2 reload${nc}"
fi

if [ ! -z "${postDeploy}" ]
then
    echo -e "${gray}♨ Executing post deploy script${nc}"
    ssh -t ${usrName}@${ip} "eval ${postDeploy}"
fi

echo -e "${green}✔ Ready.${nc}"
# echo ""
