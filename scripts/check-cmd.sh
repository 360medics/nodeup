#!/usr/bin/env bash

help=""
help="${help}\n📦 ${purple}NodeJs Server Util${nc}"
help="${help}\n${purple}----------------------------------------------------${nc}"
help="${help}\n  Usage:\n
  ${gray}nodeup <cmd> <env> --arg1=<x1> --arg2=<x2> (example: '$> nodeup deploy prod')
${nc}"
help="${help}\n  Arguments:
  -i --ip                Your server IP address\n
  -d --domain            Your server domain name\n
  -a --app-dir           App directory after /home/srv/<appDir> (default app-01234)\n
  -s --skip-npm-install  Should npm install be runned after deploy (default 1)\n
  -u --apt-upgrade       Upgrades update Debian server (default 1)\n
${nc}"

if [ -z "${1:-}" ]
then
    echo -e "${red}✗ 1st argument (command) 'nodeup <COMMAND> <env>' is required${nc}"
    echo -e $help
    exit 2
fi

if [ -z "${2:-}" ]
then
    echo -e "${red}✗ 2nd argument (environment)'nodeup <command> <ENV>' is required${nc}"
    echo -e $help
    exit 3
fi

env="$2"
script="$1"
