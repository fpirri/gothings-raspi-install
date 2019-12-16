#!/bin/bash
#                                                                    2019-12-04
#  BOOT menu script for GoThings System in the CLOUD
                                                               VERSION="0.00.02"
#
# download from:  https://github.com/fpirri/gothings-install/raw/master/c
#

#
##########################################################################
avanti(){
  # Domanda di continuazione personalizzabile
  # call:    avanti $1
  #   $1:    "<stringa di domanda>"
  echo "----------------------------------------------------------------"
  read -rsp "$1" -n 1 key
  echo
}
#
##########################################################################
pause(){
#  Domanda 'continue or exit'
  avanti 'Press any key to continue or ^C to exit ...'
}
#
##########################################################################

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo
echo "      G O T H I N G S   B O O T S T R A P"
echo
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ${VERSION}"
echo
echo "Hi there!"
echo "Your droplet was succesfully created!"
echo
echo "This script will download and run the 'GOTHINGS Control Menu'"
echo
echo "It will:"
echo "  - install docker into the droplet;"
echo "  - download and install the gothings software from github;"
echo "  - allow you to manage the gothings software from a menu."
echo
pause
echo
echo "  ... download gocloud"
wget -O gocloud https://github.com/fpirri/gothings-cloud/raw/master/gocloud
echo
echo "  ... make gocloud executable"
chmod +x gocloud
echo
echo "  ... and run it !"
./gocloud