#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

projDir=$PWD
distDir=$projDir/dist
execDir=$(dirname $(readlink $0))
remoteDir=/home/srv

source ${execDir}/colors.sh
# from here script and env variables are set
source ${execDir}/scripts/check-cmd.sh

source ${execDir}/scripts/check-vars.sh ${env}
# from here --argument(s) are set
source ${execDir}/${script}.sh ${env}
