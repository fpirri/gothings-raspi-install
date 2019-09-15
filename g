#!/bin/bash
#                                                                    2019-07-16
#  Control menu script for HLITE system
#                                                           version 0.00.01-dev
#
#  Menu per l'inizializzazione del sistema hlite
#    inspired by:
#      https://bash.cyberciti.biz/guide/Menu_driven_scripts
#
# download:
#   wget -O ~/sysstart/hliteboot/controlmenu.sh http://test.cloud2run.it/hliteboot/controlmenu.sh
#
#==============================================================================
echo
echo "========================================================= HLITE for raspi"
echo "          Control loader for HLITE docker system."
echo "========================================================================="
echo
cd ~/sysstart/hliteboot
#
# ---  environment
VERSION="0.0.1"  # dev active !
#
# ----------------------------------
# Define variables
# ----------------------------------
EDITOR=nano
PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'

DEBUGLOG=""
FILELEN=0   # Lunghezza del file in fileexists()  <-- da aggiornare
ITEXISTS=0  # 1 se il cercato esiste
FILE=""     # Nome del file in fileexists()

# ----------------------------------
# User defined function
# ----------------------------------

avanti(){
  # call:    avanti $1
  #   $1:    "<string>"
  echo "----------------------------------------------------------------"
  read -rsp "$1" -n 1 key
  echo
}

pause(){
#  continue or exit
  echo "----------------------------------------------------------------/"
  read -rsp $'Press any key to continue or ^C to exit ...' -n 1 key
}

getsysfile(){
  # call:    getfile $1 $2 $3
  #   $1:    "filename"
  #   $2:    "github project branch"
  #   $3:    "raspi directory"
  # DA FARE: Mettere default per i dirs
  #
  # example:
  #          getfile "hdirs.tar.gz" "/home/pi/hlite-install/master" "/home/pi"
  #echo 
  #echo "get file: $1, github path: $2"
  wget -O $3/$1 https://raw.githubusercontent.com/fpirri/$2/$1
}

getbootscript(){
  #   ==>    === get file + make executable
  # call:    getbootscript $1 $2 $3
  #   $1:    "filename"
  #   $2:    "github project branch"
  #   $3:    "raspi directory"
  # example:
  #          getfile "boot.sh" "hlite-install/master" "/home/pi"
  echo 
  echo "get file: $3$1"
  echo "from:     $2/$1"
  getsysfile "$1" "$2" "$3"
  chmod +x $3/$1
}


fileexists(){
  # call:    fileexists $1 $2 $3
  #   $1:    "filename"
  #   $2:    "github project branch"
  #   $3:    "raspi directory"
  # RETURN:
  #           FILELEN = length of file
  #
  # Verify file existence, get it if not
  #   --> detection not yet functioning
  #
  # example:
  #          fileexists "hlitebase.yml" "hlite-control/master" "/home/pi/dockrepo/dockimages/"

  #  -s file  True if file exists and has a size greater than zero

  FILE="$3$1"  
  if [ -s $FILE ]
  then
    FILELEN=1
  else 
    echo "$FILE does not exist"
    wget -O $3/$1 https://raw.githubusercontent.com/fpirri/$2/$1
    if [ -s $FILE ];
    then
      FILELEN=1
    else
      FILELEN=0
    fi
  fi
  return $FILELEN
}
#
##########################################################################
showsubtitle(){
  # 1. SHOW submenu header
  #
  # call:    showsubtitle $1
  #    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  # $1:"         Sub menu title"
  clear
  echo 
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "$1"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo 
}
#
##########################################################################
#
showcontainers(){
  # 1. SHOW containers status
  #               "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #  showsubtitle "         sottotitolo piu' o meno centrato"
  showsubtitle "      MANAGE:  SHOW all containers"
  docker ps -a --format "table {{.Names}}\\t{{.Image}}\\t{{.Status}}"
  sleep 2
  echo
  avanti "Any key to return to main menu"
}
#
##########################################################################
hlitebase(){
  RIPETI=1
  until [ $RIPETI -gt 3 ]
    do
      showsubtitle "         MANAGE:  HLITE base container"
      echo "Please choose one of the options below:"
      echo " 1) START    HLITE base containers"
      echo " 2) PAUSE    HLITE base containers"
      echo " 3) DESTROY  HLITE base containers"
      echo " 4) RETURN   to main menu"
      read -rsp $'Your choice: ' -n 1 key
      case $key in
        1)  # START base subsystem
            echo
            echo
            echo "---------------------------------------------------------"
            echo "Use docker-compose to START the base containers"
            fileexists "hlitebase.yml" "hlite-control/master" "/home/pi/dockrepo/sysdata/appdata/"
            echo "fileexist return: $FILELEN"
            echo
            if [ $FILELEN -eq 0 ]
            then
              echo "Cannot find hlitebase.yml file on github"
              echo "Operation stopped."
              sleep 3
            else
              echo "Starting docker-compose ..."
              docker-compose -f /home/pi/dockrepo/sysdata/appdata/hlitebase.yml up -d
              echo "Done."
              sleep 2
            fi
            RIPETI=1
            ;;
        2)  # PAUSE base subsystem
            echo
            echo
            echo "---------------------------------------------------------"
            echo "Use docker-compose to STOP the base containers"
            echo
            echo "This operation will STOP your base containers"
            echo "You can re-run them with the START operation."
            echo "Permanent user data will NOT be destroyed"
            read -rsp "Do you like to STOP base containers? [y/N] " -n 1 key
            case "$key" in
                [yY]) 
                    echo
                    fileexists "hlitebase.yml" "hlite-control/master" "/home/pi/dockrepo/sysdata/appdata/"
                    echo "fileexist return: $FILELEN"
                    echo
                    if [ $FILELEN -le 0 ]
                    then
                      echo "Cannot find hlitebase.yml file on github"
                      echo "Operation stopped."
                      sleep 3
                    else
                      echo "Using docker-compose to stop base containers ..."
                      docker-compose -f /home/pi/dockrepo/sysdata/appdata/hlitebase.yml stop
                      echo
                      echo "done."
                    fi
                    sleep 2
                    ;;
                *)
                    echo
                    echo "Back to choice"
                    sleep 2
                    ;;
            esac
            RIPETI=2
            ;;
        3)  # DESTROY base subsystem
            echo
            echo
            echo "---------------------------------------------------------"
            echo "Use docker-compose to STOP & DESTROY the base containers"
            echo 
            echo "------------------ ATTENTION, please,"
            echo "This operation will STOP & DESTROY your running base containers !"
            echo "Anyway you can re-create and run them with the START operation."
            echo "Permanent user data will NOT be destroyed"
            read -rsp "Do you like to STOP & DESTROY? [y/N] " -n 1 key
            case "$key" in
                [yY]) 
                    echo
                    fileexists "hlitebase.yml" "hlite-control/master" "/home/pi/dockrepo/sysdata/appdata/"
                    echo "fileexist return: $FILELEN"
                    echo
                    if [ $FILELEN -le 0 ]
                    then
                      echo "Cannot find hlitebase.yml file on github"
                      echo "Operation stopped."
                      sleep 3
                    else
                      echo "Using docker-compose to stop & destroy base containers ..."
                      docker-compose -f /home/pi/dockrepo/sysdata/appdata/hlitebase.yml down
                      echo
                      echo "done."
                    fi
                    sleep 2
                    ;;
                *)
                    echo
                    echo "Back to choice"
                    sleep 2
                    ;;
            esac
            RIPETI=3
            ;;
        4)  # NON eseguito, si ritorna al controlmenu
            echo "Ritorno ..."
            RIPETI=4
            ;;
      esac
    done
  #
}

##########################################################################
###################################### Functions for node apps management
#
##########################################################################
# Verifica esistenza applicazione in nodedata
#     <-- se esiste il file *.tar.gz si presume che l'applicazione esista
#         <-- si va avanti senza altre azioni
#             <-- si presume che prima sia andato tutto bene ...
#       <-- se il file *.tar.gz non c'e' si prova a scaricare il file da github
#           <-- se si trova il .tar.gz, questo viene espanso senza alcun avviso ...
#     <-- si verifica se esite il .../sysdata/nodedata/*/config.json
#         <-- se esite si esce positivamente
#         <-- altrimenti si esce con errore (FILELEN==0)
#     
findnodeapp(){
  # call:    findnodeapp $1 $2 $3
  #   $1:    "appname"
  #   $2:    "github project branch"
  #   $3:    "raspi directory"
  # RETURN:
  #           ITEXISTS = 1 se esiste, 0 altrimenti
  #
  # Verify file existence, get it from github if not
  #
  # example:
  #          fileexists "hlitedev" "hlite-apps/master" "/home/pi/dockrepo/sysdata/nodedata/"
  #
  #  -s file  True if file exists and has a size greater than zero
  DEBUGLOG=""
  FILEGZ="/home/pi/sysarchive/$1.tar.gz"
  DEBUGLOG="DEBUG INFO | Il file cercato e': $FILEGZ"
  if [ -s $FILEGZ ]
  then
    ITEXISTS=1
    DEBUGLOG="$DEBUGLOG | $FILEGZ esiste"
  else 
    DEBUGLOG="$DEBUGLOG | $FILEGZ does not exist"
    wget -O $FILEGZ https://raw.githubusercontent.com/fpirri/$2/$1.tar.gz
    if [ -s $FILEGZ ];
    then
      tar -xzvf $FILEGZ -C $3
      DEBUGLOG="$DEBUGLOG | $FILEGZ expanded in "
    fi
  fi
  FILEJSON="$APPDIR$1/package.json"
  DEBUGLOG="$DEBUGLOG | verify $FILEJSON existence"
  if [ -s $FILEJSON ];
  then
    echo $DEBUGLOG
    ITEXISTS=1
  else
    ITEXISTS=0
    echo $DEBUGLOG
    echo
    echo "-----------------------------------------------------------------"
  fi
  #echo $DEBUGLOG   ########### Stampa sempre mentre sviluppo ...
  return $ITEXISTS
}
#
######################################
nodedev(){
  # 1. MANAGE HLITE application - node development containers
  #
  APPDIR="/home/pi/dockrepo/sysdata/nodedata/"
  HLAPP="nodedev"
  DEVREADY=0
  #        <--name of the managed  node application
  #
  RIPETI=1
  until [ $RIPETI -gt 4 ]
    do
      showsubtitle "           MANAGE:  Node js app environment"
      echo "Please choose one of the options below:"
      echo " 1) START    NODE app container"
      echo " 2) PAUSE    NODE app container"
      echo " 3) DESTROY  NODE app container"
      echo " 4) CHOOSE   your application"
      echo " 5) RETURN   to main menu"
      echo "-----------------------------------------------------------------"
      echo "                  selected application name : ${HLAPP}"
      echo "-----------------------------------------------------------------"
      # VERIFY HLAPP.tar.gz source archive is really available
      # it should be in /home/pi/dockrepo/sysdata/nodedata/ directory
      echo
      findnodeapp "${HLAPP}" "hlite-apps/master" "${APPDIR}"
      if [[ $ITEXISTS -ne 1 ]]
      then
        echo "File missing for ${HLAPP} application"
        echo "It wasn't possible to download it from github"
        echo "Please make sure the following is available and contains app data:"
        echo "  ${APPDIR}${HLAPP}/"
        echo "Please note you can put files in the directory by yourself"
        echo
        echo "You can now choice:"
        echo "  4 to choose another application"
        echo "  5 for main menu"
        echo "-----------------------------------------------------------------"
      fi
      read -rsp $'Your choice: ' -n 1 key
      case $key in
        1)  # START HLAPP container
            echo
            echo "START ${HLAPP} application"
            echo
            if [[ $ITEXISTS -ne 1 ]]
            then
              echo "Cannot find ${HLAPP} app file on github"
              echo "Moreover, the config.json wasn't in ${APPDIR}${HLAPP}/"
              echo "Operation stopped."
              sleep 4
            else
              echo "Starting docker-compose ..."
              echo "work con il file: ${APPDIR}${HLAPP}/${HLAPP}.yml"
              docker-compose -f ${APPDIR}${HLAPP}/${HLAPP}.yml up -d
              echo "Done."
              sleep 2
            fi
            break
            ;;
        2)  # PAUSE nodebase container
            echo
            echo "Use docker-compose to STOP the ${HLAPP} container"
            echo
            if [[ $ITEXISTS -ne 1 ]]
            then
              echo "Cannot find ${HLAPP} app file on github"
              echo "Moreover, the config.json wasn't in ${APPDIR}${HLAPP}/"
              echo "Operation stopped."
              sleep 4
            else
              echo "This operation will STOP your ${HLAPP} container"
              echo "You can re-run it with the START operation."
              echo "Permanent user data will NOT be destroyed"
              read -rsp "Do you like to STOP ${HLAPP} container? [y/N] " -n 1 key
              case "$key" in
                [yY]) 
                  echo
                  echo "Using docker-compose to stop ${HLAPP} container ..."
                  docker-compose -f ${APPDIR}${HLAPP}/${HLAPP}.yml stop
                  echo
                  echo "done."
                  sleep 2
                  ;;
                *)
                  echo
                  echo "Back to choice"
                  sleep 2
                  ;;
              esac
            fi
            break
            ;;
        3)  # DESTROY  $HLAPP container
            echo
            echo "Use docker-compose to STOP & DESTROY the ${HLAPP} container"
            echo 
            echo
            if [[ $ITEXISTS -ne 1 ]]
            then
              echo "Cannot find ${HLAPP} app file on github"
              echo "Moreover, the config.json wasn't in ${APPDIR}${HLAPP}/"
              echo "Operation stopped."
              sleep 4
            else
              echo "------------------ ATTENTION, please,"
              echo "This operation will STOP & DESTROY your running ${HLAPP} container !"
              echo "Anyway you can re-create and run it with the START operation."
              echo "Permanent user data will NOT be destroyed"
              read -rsp "Do you like to STOP & DESTROY ${HLAPP} container? [y/N] " -n 1 key
              case "$key" in
                [yY]) 
                  echo
                  echo "Using docker-compose to stop & destroy ${HLAPP} container ..."
                  docker-compose -f ${APPDIR}${HLAPP}/${HLAPP}.yml down
                  echo
                  echo "done."
                  sleep 2
                  ;;
                *)
                  echo
                  echo "Back to choice"
                  sleep 2
                  ;;
              esac
            fi
            break
            ;;
        4)  # CHOOSE Application
            echo
            echo "-----------------------------------------------------------------"
            echo "  INIT hlite node application"
            echo "-----------------------------------------------------------------"
            echo            
            read -rp "Please enter application name: " app
            echo
            echo "you entered: $app"
            echo
            echo "------------------ ATTENTION, please,"
            echo "This operation will initialize data for the ${app} application."
            echo "It will STOP the (eventual) running ${app} container and will"
            echo "expand the archived data into the .../nodedata/${app}"
            echo "directory. Please be sure you like to do so."
            read -rsp "Do you like to INIT ${app} application from the archive? [y/N] " -n 1 key
            case "$key" in
              [yY]) 
                echo
                echo "Set application name: $app"
                HLAPP="$app"
                echo
                echo "Stop ${app} container ..."
                docker stop ${app}
                echo "expand user data in .../nodedata/${app} directory ..."
                FILEGZ="/home/pi/sysarchive/$app.tar.gz"
                APPDIR="/home/pi/dockrepo/sysdata/nodedata/"
                echo "FILEGZ: $FILEGZ - APPDIR: $APPDIR"
                tar -xzvf $FILEGZ -C $APPDIR
                echo
                echo "done."
                sleep 4
                break
                ;;
              *)
                echo
                echo "Back to choice"
                sleep 2
                ;;
            esac
            sleep 4
            key=4
            ;;
        5)  # NON eseguito, si ritorna al controlmenu
            echo "5"
            ;;
      esac
      RIPETI=$key
    done
  #
}

boh(){
  # BOH!  Da Fare
  echo 
  echo
  echo "-------------------------------------------------------------- ?:"
  echo
  echo "Qui ci sara' una funzione, quando sara' fatta ..."
  echo
  #exit
  pause "?"
}

userdir(){
  # 1. MANAGE user dirs content
  menu(){
    clear
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "    B A C K U P  /  R E S T O R E"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo
    echo "Please choose one of the options below:"
    echo " 1) GET     User content from archive"
    echo " 2) BACKUP  User content into archive"
    echo " 3) SET     archive number (0..9)"
    echo " 4) RETURN  to main menu"
  }
  #
  echo 
  echo 
  echo "-----------------------------------------------------------------"
  echo "        MANAGE:  user dirs content"
  RIPETI=1
  GZVersion=0
  until [ $RIPETI -gt 3 ]
    do
      HDIRS="/home/pi/sysarchive/hdirs-${GZVersion}.tar.gz"
      menu
      echo "------------------- Archive number:  $GZVersion"
      read -rsp $'Your choice: ' -n 1 key
      case $key in
        1)  # GET User content from archive
            echo
            echo "------------------------------------------------------------"
            echo "GET User content from archive : $GZVersion"
            echo "------------------------------------------------------------"
            echo
            echo "ATTENTION, please !"
            echo "This operation will DESTROY current content in the user area,"
            echo "replacing it with the archived content."
            read -rsp "Do you like to replace? [y/N] " -n 1 key
            case "$key" in
                [yY]) 
                    echo
                    echo "Replacing user content from archive number $GZVersion"
                    sleep 3
                    sudo tar -xzvf ${HDIRS} -C /
                    echo "done."
                    ;;
                *)
                    echo
                    echo "Back to choice"
                    sleep 1
                    ;;
            esac
            RIPETI=1
            ;;
        2)  # BACKUP User content into archive
            echo
            echo "------------------------------------------------------------"
            echo "SAVE current user content in the archive : $GZVersion"
            if [ $GZVersion -gt 0 ]
            then
              echo "Please note this operation will REPLACE current archive content"
              read -rsp "Do you like to replace? [y/N] " -n 1 key
              case "$key" in
                  [yY]) 
                      echo
                      echo "Store user's content into archive ..."
                      sleep 2
                      sudo tar -zcvf ${HDIRS} /home/pi/dockrepo/sysdata
                      echo "done."
                      sleep 3
                      ;;
                  *)
                      echo
                      echo "Back to choice"
                      sleep 1
                      ;;
              esac
            else
              echo
              echo "-------------------"
              echo "It is forbidden to replace  archive # 0"
              echo "Please change archive number to save current content"
              echo "-------------------"
              sleep 3
            fi
            RIPETI=2
            ;;
        3)  echo
            echo "--------------------------------------------"
            read -rsp $'Please input a digit from 0 to 9: ' -n 1 choice
            case $choice in
              0) GZVersion=0
                 ;;
              1) GZVersion=1
                 ;;
              2) GZVersion=2
                 ;;
              3) GZVersion=3
                 ;;
              4) GZVersion=4
                 ;;
              5) GZVersion=5
                 ;;
              6) GZVersion=6
                 ;;
              7) GZVersion=7
                 ;;
              8) GZVersion=8
                 ;;
              9) GZVersion=9
                 ;;
              *) echo
                 echo "Wrong choice!"
                 sleep 2
                 ;;
            esac
            ;;
        4)  echo "4"
            echo "key: $key"
            RIPETI=4
            ;;
      esac
    done
  #
}

# function to display menus
show_menus() {
  clear
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "    H L I T E   C O N T R O L   MENU"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo
  echo "1. SHOW      containers (docker ps -a)"
  echo "2. BASE      MANAGE hlite base containers"
  echo "3. NODE      MANAGE node js development containers"
  echo "4. PYTHON    MANAGE python development containers"
  echo "5. ToDo      work-in-progress ..."
  echo "6. MANAGE    user data"
}
# read input from the keyboard and take a action
# invoke the function according to the entered number
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options(){
	local choice
  read -rsp $'Enter choice [ 1..6 or ^C to exit ] ' -n 1 choice
	case $choice in
		1) showcontainers;;
		2) hlitebase;;
		3) nodedev;;
		4) boh;;
		5) boh;;
		6) userdir;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}
 
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGQUIT SIGTSTP
#trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------

while true
do
	show_menus
	read_options
done

exit
