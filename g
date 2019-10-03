#!/bin/bash
#                                                                    2019-07-19
#  Control menu script for GOTHINGS system
#                                                           version 0.00.02-dev
#
#  Menu per l'inizializzazione del sistema gothings
#    Basic idea coming from:
#      https://bash.cyberciti.biz/guide/Menu_driven_scripts
#
# download:
#   wget -O ~/sysstart/hliteboot/controlmenu.sh http://test.cloud2run.it/hliteboot/controlmenu.sh
#
#==============================================================================
echo
echo "====================================================== GOTHINGS for raspi"
echo "        Control loader for GOTHINGS docker system."
echo "========================================================================="
echo
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

HOMEDIR="/home/pi/"
DEBUGLOG=""
###############################################FILELEN=0   # Lunghezza del file in fileexists()  <-- da aggiornare
ITEXISTS=0  # 1 se il cercato esiste
FILE=""     # Nome del file in fileexists()
MENUTRAP=0  #  66 : exit menu


cd ${HOMEDIR} #work on user 'pi' home

# ----------------------------------
# User defined functions
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

#
##########################################################################
getgitfile(){    # Lettura file da github
  #
  #  use globals:
  #    DEBUGLOG=""     # utile nel debug
  #    ITEXISTS=0      #  1 : file esiste    0 : file assente
  #
  #
  #     <-- se esiste il file $1 ed ha lunghezza > 0 :
  #         <-- si va avanti senza altre azioni
  #     <-- altrimenti si prova a scaricare il file da github               AGGIUSTARE dopo ......
  #     <-- si riprova il test di lunghezza
  #         se non funziona si torna con ITEXISTS=0
  #     
  # call:    findnodeapp $1 $2 $3
  #   $1:    "file"
  #   $2:    "github project branch"
  #   $3:    "raspi path after /home/pi/ "
  # RETURN:
  #           ITEXISTS = 1 se esiste, 0 altrimenti
  #
  # Verify file existence, get it from github if not
  #
  # example:
  #          getgitfile "gotdirs.tar.gz" "gothings-install/master/" "dockrepo/sysarchive/"
  #
  #  bash:  -s file  True if file exists and has a size greater than zero
  FILEGIT="/home/pi/$3$1"
  DEBUGLOG="|| getgitfile() INFO || Il file cercato e': $FILEGIT"
  if [[ -s $FILEGIT ]]
  then
    ITEXISTS=1    # file exists and length > 0
    DEBUGLOG="$DEBUGLOG | $FILEGIT esiste |"
  else            # si prova a scaricarlo
    DEBUGLOG="$DEBUGLOG | $FILEGIT does not exist |"
    wget -O $FILEGIT https://raw.githubusercontent.com/fpirri/$2$1
    if [[ -s $FILEGIT ]]
    then
      ITEXISTS=1    # file exists and length > 0
      DEBUGLOG="$DEBUGLOG | $FILEGIT trovato |"
    else
      ITEXISTS=0    # file introvabile !
      DEBUGLOG="$DEBUGLOG | $FILEGIT introvabile |"
      echo $DEBUGLOG                               ########### Stampa sempre mentre sviluppo ...
    fi
  fi
  return $ITEXISTS
}
#
#
##########################################################################
showsubtitle(){
  # 1. SHOW submenu header
  #
  # call:    showsubtitle $1
  #    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  # $1:"         Sub menu title"
  #
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
  RIPETI=1
  until [[ $RIPETI -gt 3 ]]
    do
      # 1. SHOW containers status
      #               "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      #  showsubtitle "         sottotitolo piu' o meno centrato"
      showsubtitle "      MANAGE:  SHOW all containers"
      docker ps -a --format "table {{.Names}}\\t{{.Image}}\\t{{.Status}}"
      echo
      echo "------------------------------------"
      sleep 2
      read -rsp "Do you like to read again containers status? [y/N] " -n 1 key
      case "$key" in
          [yY])
            RIPETI=1
            ;;
          *)
            RIPETI=4
            ;;
      esac
   done
}
#
#
##########################################################################
stopmenu(){
  #  $1 :  nome del file non trovato
  echo 
  echo "------------------------------------------------------"
  echo -e "${RED} ERROR on file: $1 - debug message: ${STD}"
  echo $DEBUGLOG
  echo $2
  echo "------------------------------------------------------"
  echo "Cannot continue."
  echo 
  MENUTRAP=66
  return 66
}
#
##########################################################################
gothingsbase(){
  # verifica esistenza files applicazione base
  FILEBASEGZ="basedirs.tar.gz"           # deve esistere il file tar.gz in sysarchive
  GITBR="gothings-install/master/"
  PIDIRGZ="dockrepo/sysarchive/"
  getgitfile ${FILEBASEGZ} $GITBR $PIDIRGZ
  if [[ $ITEXISTS -ne 1 ]]
  then                             # SI INTERROMPE TUTTO se basedirs.tar.gz non esiste
    stopmenu "${FILEBASEGZ}"  "file ${FILEBASEGZ} is essential for control menu"
    return 66                      # interrommpere il menu principale
  else
    # il file .tar.gz esiste, proseguiamo cercando il file "marcatore"
    
    FILEMARK="${HOMEDIR}dockrepo/dockimages/base/base.dirs"
    if [[ ! -s $FILEMARK ]]
    then                            # il marcatore NON esiste, espandiamo basedirs.tar.gz
      echo
      echo "File ${FILEMARK} does not exists, try to expand ${FILEBASEGZ} ..."
      echo
      tar -xzvf "${PIDIRGZ}${FILEBASEGZ}" -C $HOMEDIR
      DUMMY=$?
      if [[ ! $DUMMY -eq 0 ]]
      then
        echo "tar returned: $DUMMY"
        echo
        stopmenu "${PIDIRGZ}${FILEBASEGZ}"  "tar returned: $DUMMY : file expantion failed"
        return 66                      # interrommpere il menu principale
      fi
      echo "done."
      sleep 4
    fi
    # verifichiamo esistenza file .yml
    FILEMARK="${HOMEDIR}dockrepo/sysdata/base/gothingsbase.yml"
    if [[ ! -s $FILEMARK ]]
    then                           # il marcatore NON esiste, SI INTERROMPE TUTTO
      DEBUGLOG="|| BASE files check | Essential file missing ||"
      stopmenu "${FILEMARK}" "file ${FILEMARK} is essential for control menu"
    return 66                      # interrommpere il menu principale
    fi
  fi
# esegui menu applicazione base  
  RIPETI=1
  until [[ $RIPETI -gt 10 ]]
    do
      showsubtitle "         MANAGE:  GOTHINGS base container"
      echo "Please choose one of the options below:"
      echo " 1) SHOW     all containers"
      echo " 2) START    GOTHINGS base containers"
      echo " 3) PAUSE    GOTHINGS base containers"
      echo " 4) DESTROY  GOTHINGS base containers"
      echo " 5) RETURN   to main menu"
      read -rsp $'Your choice: ' -n 1 key
      case $key in
        1)  # SHOW all containers
            showcontainers
            RIPETI=4
            ;;
        2)  # START base subsystem
            echo
            echo
            echo "---------------------------------------------------------"
            echo "Use docker-compose to START the base containers"
            echo
            echo "Starting docker-compose ..."
            docker-compose -f /home/pi/dockrepo/sysdata/base/gothingsbase.yml up -d
            echo "Done."
            sleep 2
            ;;
        3)  # PAUSE base subsystem
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
                  echo "Using docker-compose to stop base containers ..."
                  docker-compose -f /home/pi/dockrepo/sysdata/base/gothingsbase.yml stop
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
            RIPETI=2
            ;;
        4)  # DESTROY base subsystem
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
                  echo "Using docker-compose to stop base containers ..."
                  docker-compose -f /home/pi/dockrepo/sysdata/base/gothingsbase.yml down
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
            RIPETI=3
            ;;
        5)  # NON eseguito, si ritorna al controlmenu
            echo "Ritorno ..."
            RIPETI=99
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
  #          fileexists "gothingsdev" "gothings-apps/master" "/home/pi/dockrepo/sysdata/nodedata/"
  #
  #  -s file  True if file exists and has a size greater than zero
  DEBUGLOG=""
  FILEGZ="/home/pi/sysarchive/$1.tar.gz"
  DEBUGLOG="DEBUG INFO | Il file cercato e': $FILEGZ"
  if [[ -s $FILEGZ ]]
  then
    ITEXISTS=1
    DEBUGLOG="$DEBUGLOG | $FILEGZ esiste"
  else 
    DEBUGLOG="$DEBUGLOG | $FILEGZ does not exist"
    wget -O $FILEGZ https://raw.githubusercontent.com/fpirri/$2/$1.tar.gz
    if [[ -s $FILEGZ ]]
    then
      tar -xzvf $FILEGZ -C $3
      DEBUGLOG="$DEBUGLOG | $FILEGZ expanded in "
    fi
  fi
  FILEJSON="$APPDIR$1/package.json"
  DEBUGLOG="$DEBUGLOG | verify $FILEJSON existence"
  if [[ -s $FILEJSON ]]
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
  # 1. MANAGE GOTHINGS application - node development containers
  #
  APPDIR="/home/pi/dockrepo/sysdata/nodedata/"
  HLAPP="nodedev"
  DEVREADY=0
#====================================================> CONTROLLA che nodedata esista
  MENUTRAP=66
  return
  #
  #        <--name of the managed  node application
  #
  RIPETI=1
  until [[ $RIPETI -gt 4 ]]
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
      findnodeapp "${HLAPP}" "gothings-apps/master" "${APPDIR}"
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
            echo "  INIT gothings node application"
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
  until [[ $RIPETI -gt 3 ]]
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
            if [[ $GZVersion -gt 0 ]]
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
#
# function to display menus
show_menus() {
  clear
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "    G O T H I N G S   C O N T R O L   MENU"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo
  echo "1. SHOW      containers (docker ps -a)"
  echo "2. BASE      MANAGE gothings base containers"
  echo "3. NODE      MANAGE node js development containers"
  echo "4. PYTHON    MANAGE python development containers"
  echo "5. ToDo      work-in-progress ..."
  echo "6. MANAGE    user data"
}
#
# read input from the keyboard and take a action
# invoke the function according to the entered number
read_options(){
	local choice
  read -rsp $'Enter choice [ 1..6 or ^C to exit ] ' -n 1 choice
	case $choice in
		1) showcontainers;;
		2) gothingsbase;;
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
  # internal trap
  if [[ ${MENUTRAP} -eq 66 ]]
  then
    break  #-- stop menu
  fi
	show_menus
	read_options
done
echo "Shell terminated."
echo
#
##########################################################################
##################  Templates utili durante lo sviluppo  #################
##########################################################################
#
xxx_template_per_git_file(){  ############################################
  #### usare questo template se il file e' ESSENZIALE: se non esiste si ferma il MENU
  echo
  FILE="<nomefile>"
  GITBR="gothings-install/master/"  # dir su github dove va preso il file
  PIDIR=""                          # path da aggiungere a HOMEDIR == /home/pi/
  getgitfile "${FILE} $GITBR $PIDIR"
  if [[ $ITEXISTS -ne 1 ]]
  then ########## DA FARE se il file MANCA  (caso 'interrompi TUTTO' e si esce dal menu)
    stopmenu ${FILE} "File ${FILE} is essential for control menu"
  else ########## DA FARE se il file esiste ...
    echo 
    echo "< CI SONO !! >"
    ##
    ##
    echo
    echo "<guarda cosa ho fatto!!>"
    sleep 5
  fi
}
################## end xxx_template_per_git_file   #######################
#
xxx_template_per_file_exists(){  #########################################
    # verifichiamo esistenza file .yml
    FILEMARK="${HOMEDIR}${<path-to-file>}"
    if [[ -s $FILEMARK ]]
    then                            # il marcatore esiste
      ITEXISTS=1
      # qui si esegue il caso positivo, dove il file ha lunghezza >0
    else                            # il marcatore NON esiste, SI INTERROMPE TUTTO
      ITEXISTS=0
      # qui si esegue il caso negativo, dove il file non esiste oppure ha lunghezza 0
    fi
}
################# end xxx_template_per_file_exists   #####################
#
xxx_template_per_stopmenu(){  ############################################
  #  $1 :  nome del file non trovato
  #  $2 :  riga di debug aggiuntiva
  echo 
  echo "------------------------------------------------------"
  echo -e "${RED} ERROR on file: $1 - debug message: ${STD}"
  echo $DEBUGLOG
  echo $2
  echo "------------------------------------------------------"
  echo "Cannot continue."
  echo 
  MENUTRAP=66
  return 66
}
################### end xxx_template_per_stopmenu   ######################
#
xxx_template_scelta_yn(){  ############################################
# esegui menu applicazione base  
  RIPETI=1
  until [[ $RIPETI -gt 3 ]]
    do

            echo "Permanent user data will NOT be destroyed"
            read -rsp "Do you like to STOP base containers? [y/N] " -n 1 key
            case "$key" in
                [yY]) 
                  echo
                  echo "Using docker-compose to stop base containers ..."
                  docker-compose -f /home/pi/dockrepo/sysdata/base/gothingsbase.yml stop
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
################# end xxx_template_per_file_exists   #####################


