#!/usr/bin/env bash

env="$1"
ip=
domain=
appDir=
usrName=
usrPwd=
pm2=1
npmInstall=1
aptUpgrade=1
excludeDirs=
postDeploy=

if [[ -f "$execDir/.nodeup.cnf" ]]
then
    source $execDir/.nodeup.cnf
fi

# read overriden config given by user
usrCnfFile=${projDir}/.nodeup.${env}.cnf
altCnfFile=${projDir}/.nodeup.cnf

if [[ -f "${usrCnfFile}" ]]
then
    source $usrCnfFile
elif [[ -f "${altCnfFile}" ]]
then
    source $altCnfFile
else
    echo -e "${red}✗ Cannot find local configuration file for environment ${brown}${env}${red}\n✗ Looked for ${brown}${usrCnfFile}${nc}"
    exit 2
fi

###
# Read command line arguments
###
for i in "$@"
do
case $i in
    -p=*|--ip=*)
    ip="${i#*=}"
    shift
    ;;
    -d=*|--domain=*)
    domain="${i#*=}"
    shift
    ;;
    -p2=*|--pm2=*)
    pm2="${i#*=}"
    shift
    ;;
    -a=*|--appdir=*)
    appDir="${i#*=}"
    shift
    ;;
    -s=*|--skip-npm-install=*)
    npmInstall="${i#*=}"
    shift
    ;;
    -u=*|--upgrade=*)
    aptUpgrade="${i#*=}"
    shift
    ;;
    *)
    invalid="${i#*=}"
        # unknown option(s), just skip and set defaults
    ;;
esac
done

if [ -z "$ip" ]
then
    echo -e "${cyan}⌶ Enter server IP:${nc}"
    read ip
fi

if [ -z "$domain" ] && [ "$domain" != "0" ]
then
    echo -e "${cyan}⌶ Enter domain name (for https):${nc}"
    read domain
fi

if [ -z "$appDir" ]
then
    echo -e "${cyan}⌶ Enter app directory (${appDir}):${nc}"
    read appDir
fi

if [ -z "$usrName" ]
then
    echo -e "${cyan}⌶ Enter new username (${usrName}):${nc}"
    read appDir
fi

if [ -z "$usrPwd" ]
then
    echo -e "${cyan}⌶ Enter user password (${usrPwd}):${nc}"
    read appDir
fi
