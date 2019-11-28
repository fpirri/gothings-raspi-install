#!/bin/bash
#                                                                    2019-07-19
#  Control menu script for GOTHINGS system
                                                                 VERSION="0.00.07"
#
#  Menu per l'inizializzazione del sistema gothings
#    Basic idea coming from:
#      https://bash.cyberciti.biz/guide/Menu_driven_scripts
#
# download:
#   wget -O ~/sysstart/hliteboot/controlmenu.sh http://test.cloud2run.it/hliteboot/controlmenu.sh
#
#==============================================================================
#  AGGIORNAMENTI DA FARE
#    - elimina gli:   **ELIMINARE**                                                    **ELIMINARE**
#    - ri-posizionare le inizializzazioni
#        <-- verifica base: all'inizio, con ricarica automatica
#          <-- basedirs.tar.gz DEVE essere aggiustato (anche a mano va bene)
#        <-- verifica per ogni applicazioni non-base
#          <-- chiamare uno script in .../dockimages/<app>/<app.init>
#            <-- al momento ci si limita a chiamare un singolo script esterno ...
#        <-- generalizzare per le app utente                                                 DA FARE
#
#########
#==============================================================================
echo
echo "====================================================== GOTHINGS for raspi"
echo "        Control loader for GOTHINGS docker system."
echo "========================================================================="
echo
#
# For the execution logic, please search:     Main Logic execution
#
# ----------------------------------
# Define variables
#
#-----------------   inherit by subscripts
EDITOR=nano
PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'
HOMEDIR="/home/pi/"

#-----------------   GLOBAL da ridefinire
DEBUGLOG=""
RETLEVEL=0  # 0 : tutto OK; 1+ : situazione non valida ...
ITEXISTS=0  # 1 se il cercato esiste, 0 altrimenti
FILE=""     # Nome del file in fileexists()
MENUTRAP=0  #  66 : exit menu

cd ${HOMEDIR} #work on user 'pi' home

# ----------------------------------
# User defined functions
# ----------------------------------
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
boh(){
  # BOH!  Questa funzione e' ancora DA INIZIARE
  echo 
  echo
  echo "-------------------------------------------------------------- ?:"
  echo
  echo "Qui ci sara' una funzione, quando sara' fatta ..."
  echo
  #exit
  pause "?"
}
#
##########################################################################
toupdate(){
  #  Funzione IN CORSO DI MODIFICA
  echo 
  echo
  echo "------------------------------------------------------------ ???:"
  echo
  echo "This function will change scope."
  echo "A new definition & rewriting is on course"
  echo
  #exit
  pause "?"
}
#
##########################################################################
errmessage(){
  #  $1 :  nome del file non trovato
  #  $2 :  avviso all'utente, come '... il file xxx e' essenziale ...'
  echo 
  echo "------------------------------------------------------"
  echo -e "${RED} ERROR on file: $1 - debug message: ${STD}"
  echo $DEBUGLOG
  echo -e "$2"
  echo "------------------------------------------------------"
  echo 
}
#
##########################################################################
stopmenu(){
  #  $1 :  nome del file non trovato
  #  $2 :  avviso all'utente, come '... il file xxx e' essenziale ...'
  errmessage "$1" "$2"
  echo "Cannot continue."
  echo 
  MENUTRAP=66
  RETLEVEL=66
  return 66
}
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
getgitfile(){    # Lettura file da github
  # Verify file existence, get it from github if not
  #    eventually, make it executable  (input var $4=="EXEC")
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
  # call :    findnodeapp $1 $2 $3 [$4]
  #   $1 :    "nomefile"
  #   $2 :    "github project branch"
  #   $3 :    "raspi path after $HOMEDIR"
  #   $4 :    optional input variable, make file executable if value is "EXEC"
  # RETURN:
  #           ITEXISTS = 1 se esiste, 0 altrimenti
  #####
  # example:
  #          getgitfile "gotdirs.tar.gz" "gothings-install/master/" "dockrepo/sysarchive/"
  #
  #  bash:  -s file  True if file exists and has a size greater than zero
  FILEGIT="${HOMEDIR}$3$1"
  DEBUGLOG="|| getgitfile() INFO || Il file cercato e': $FILEGIT"
  if [[ -s $FILEGIT ]]; then
    ITEXISTS=1    # file exists and length > 0
    DEBUGLOG="$DEBUGLOG | $FILEGIT esiste |"
  else            # si prova a scaricarlo
    local githubfile
    githubfile="https://raw.githubusercontent.com/fpirri/$2$1"
    DEBUGLOG="$DEBUGLOG | $FILEGIT does not exist | download githubfile: $githubfile |"
    wget -O "$FILEGIT" "$githubfile"
    if [[ -s $FILEGIT ]]; then
      ITEXISTS=1    # file exists and length > 0
      DEBUGLOG="$DEBUGLOG | $FILEGIT trovato |"
      if [ "$4" == "EXEC" ]; then      # option: make it executable
        chmod +x "$FILEGIT"
      fi
    else
      ITEXISTS=0    # file introvabile !
      DEBUGLOG="$DEBUGLOG | $FILEGIT introvabile |"
      echo $DEBUGLOG                               ########### Stampa sempre mentre sviluppo ...
    fi
  fi
  return $ITEXISTS
}
#
##########################################################################
verifybase() {
  # verifica esistenza files applicazione base
  # eventuale espansione da file archivio
  # 
  RETLEVEL=0 #-- si parte con 'tutto bene'
  FILEBASEGZ="basedirs.tar.gz"           # deve esistere il file tar.gz in sysarchive
  GITBR="gothings-base/master/dockrepo/sysarchive/"
  PIDIRGZ="dockrepo/sysarchive/"
  getgitfile "${FILEBASEGZ}" "$GITBR" "$PIDIRGZ"
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
      # sudo tar xpf $FILEGZ -v --show-transformed -C $3     <-- preserva permission & ownership
      sudo tar xpf "${PIDIRGZ}${FILEBASEGZ}" -C $HOMEDIR
      #  tar -xzvf "${PIDIRGZ}${FILEBASEGZ}" -C $HOMEDIR
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
  # se si arriva qui significa che i file 'base' sono installati
  RETLEVEL=0
  return ${RETLEVEL}
}
#
##########################################################################
consoleexit() {
  # RETURN to raspberry console
  echo
  echo
  echo "Thank you for using GOTHINGS !"
  echo
  echo "Exiting ..."
  sleep 2
  exit 0
}
#
##########################################################################
updategmenu() {
  echo
  echo
  echo "---------------------------------------------------------"
  echo "UPDATE Gothings Control Menu  (this application)"
  echo
  echo "This operation downloads the last version from GITHUB"
  echo "This menu will be overwritten and re-executed"
  echo "Please note you need a working internet connection to go"
  echo
  read -rsp "Do you like to download last version of this menu? [y/N] " -n 1 key
  case "$key" in
    [yY]) 
      echo
      echo "... download 'g'"
      echo
      FILE="g"
      GITBR="gothings-install/master/"  # dir su github dove va preso il file
      PIDIR=""                          # path da aggiungere a HOMEDIR == /home/pi/
      getgitfile "${FILE}" "$GITBR" "$PIDIR"
      if [[ $ITEXISTS -ne 1 ]]
      then ########## DA FARE se il file MANCA  (caso 'interrompi TUTTO' e si esce dal menu)
        echo 
        echo "------------------------------------------------------"
        echo -e "${RED} ERROR on file: ${FILE} - debug message: ${STD}"
        echo $DEBUGLOG
        echo "------------------------------------------------------"
        echo "Cannot continue."
        echo 
        MENUTRAP=66
        return 66
      fi ########## Si va avanti se il file esiste ...
      chmod +x /home/pi/g
      echo
      echo "GOTHINGS CONTROL MENU is now updated"
      sleep 4
      ./g
      echo "exit from g download"
      MENUTRAP=67
      ;;
    *)
      echo
      echo "Back to choice"
      sleep 2
      ;;
  esac
  RIPETI=4
}
#
##########################################################################
##########################################################################
###################                  Dovra' essere trasformato in 'MANAGE containers & applications'
gothingsinstall(){ ###################                                                 **ELIMINARE**
  # Initialize and install gothings base & applications
  #verifybase  <-- spostato in prerequire                                              **ELIMINARE**
  # esegui menu applicazione base  
  RIPETI=1
  until [[ $RIPETI -gt 10 ]]
    do
      showsubtitle "         INSTALL:  GOTHINGS base & applications"
      echo "Please choose one of the options below:"
      echo " 1) BASE     install BASE nodejs modules"
      echo " 2) VUE      install vue framework"
      echo " 3) PYTHON   install python applications"
      echo " 4) UPDATE   GOTHINGS Control Menu"
      echo " 5) RETURN   to main menu"
      read -rsp $'Your choice: ' -n 1 key
      case $key in
        1)  # INSTALL base subsystem
            echo
            echo
            echo "---------------------------------------------------------"
            echo "Use docker-compose to install the BASE subsystem"
            echo
            echo 
            echo "Install gothings docker networks"
            echo "Please note that the following will show 'already exists' errors"
            echo "if the network was already installed"
            echo 
            echo "- gothingsnet"
            docker network create -d bridge --subnet 172.29.196.0/24 --gateway 172.29.196.1 gothingsnet  
            echo "- servicenet"
            docker network create -d bridge --subnet 172.29.195.0/24 --gateway 172.29.195.1 servicenet
            echo
            echo
            echo "Starting docker-compose ..."
            docker-compose -f /home/pi/dockrepo/sysdata/base/gothingsbaseinstall.yml up -d
            echo "Compose: done."
            echo
            echo "Wait completion of install ..."
            docker logs -f base
            echo
            echo "NPM INSTALL done."
            sleep 4
            RIPETI=1
            ;;
        2)  # ?
            echo
            echo
            echo "---------------------------------------------------------"
            echo "Verify app install script exists"
            # verifichiamo esistenza file
            FILEG="vuedev_g"           # deve esistere il file tar.gz in sysarchive
            GITBR="gothings-install/master/"
            PIDIRGZ="dockrepo/dockimages/vuedev/"
            getgitfile ${FILEG} $GITBR $PIDIRGZ
            if [[ $ITEXISTS -ne 1 ]]
              then                           # SI INTERROMPE TUTTO se vuedev_g non esiste
              stopmenu "${FILEG}"  "file ${FILEG} is essential for control menu"
              return 66                      # interrommpere il menu principale
            fi
            # il file dockrepo/dockimages/vuedev/vuedev_g esiste, proseguiamo
            chmod +x "${PIDIRGZ}${FILEG}"
            echo "Exec VUEDEV install script"
            echo
            sleep 3
            "${PIDIRGZ}${FILEG}"
            RISULTATO=$?
            echo
            echo "VUEDEV done. Result code is: ${RISULTATO}"
            if [[ ${RISULTATO} -eq 127 ]]
            then
              echo "Cannot find VUEDEV install script"
            elif [[ ${RISULTATO} -eq 126 ]]
            then
              echo "VUEDEV script is not executable"
            elif [[ ${RISULTATO} -eq 0 ]]
            then
              echo "Result OK"
            fi
            sleep 5
            RIPETI=2
            ;;
        3)  # ?
            boh
            RIPETI=3
            ;;
        4)  # ?
            echo
            echo
            echo "---------------------------------------------------------"
            echo "UPDATE Gothings Control Menu  (this application)"
            echo
            echo "This operation downloads the last version from GITHUB"
            echo "This menu will be overwritten and re-executed"
            echo "Please note you need a working internet connection to go"
            echo
            read -rsp "Do you like to download last version of this menu? [y/N] " -n 1 key
            case "$key" in
              [yY]) 
                echo
                echo "... download 'g'"
                echo
                FILE="g"
                GITBR="gothings-install/master/"  # dir su github dove va preso il file
                PIDIR=""                          # path da aggiungere a HOMEDIR == /home/pi/
                CALL="${FILE} $GITBR $PIDIR"
                getgitfile ${CALL}
                if [[ $ITEXISTS -ne 1 ]]
                then ########## DA FARE se il file MANCA  (caso 'interrompi TUTTO' e si esce dal menu)
                  echo 
                  echo "------------------------------------------------------"
                  echo -e "${RED} ERROR on file: ${FILE} - debug message: ${STD}"
                  echo $DEBUGLOG
                  echo "------------------------------------------------------"
                  echo "Cannot continue."
                  echo 
                  MENUTRAP=66
                  return 66
                fi ########## Si va avanti se il file esiste ...
                chmod +x /home/pi/g
                echo
                echo "GOTHINGS CONTROL MENU is now updated"
                sleep 4
                ./g
                echo "exit from g download"
                MENUTRAP=67
                ;;
              *)
                echo
                echo "Back to choice"
                ;;
            esac
            sleep 4
            RIPETI=4
            ;;
        5)  # NON eseguito, si ritorna al controlmenu
            echo "Ritorno ..."
            RIPETI=99
            ;;
      esac
    done
  #
}
#
##########################################################################
startbase() {
  #  Start
            echo
            echo
            echo "---------------------------------------------------------"
            echo "Use docker-compose to START the base containers"
            echo
            echo "Starting docker-compose ..."
            docker-compose -f /home/pi/dockrepo/sysdata/base/gothingsbase.yml up -d
            echo "Done."
}
#
##########################################################################
#
##########################################################################
gothingsbase(){
  # Initialize and install gothings base & applications
  verifybase   # sottosistema BASE ri-verificato ad ogni chiamata di utente
  # esegui menu applicazione base  
  RIPETI=1
  until [[ $RIPETI -gt 10 ]]
    do
      showsubtitle "         MANAGE:  GOTHINGS BASE containers"
      echo "Please choose one of the options below:"
      echo " 1) SHOW     all containers"
      echo " 2) START    gothings BASE containers"
      echo " 3) PAUSE    gothings BASE containers"
      echo " 4) DESTROY  gothings BASE containers"
      echo " 0) RETURN   to main menu"
      read -rsp $'Your choice: ' -n 1 key
      case $key in
        1)  # SHOW all containers
            showcontainers
            RIPETI=1
            ;;
        2)  # START base subsystem
            startbase
            sleep 5
            RIPETI=2
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
                  sleep 5
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
                  sleep 5
                  ;;
                *)
                  echo
                  echo "Back to choice"
                  sleep 2
                  ;;
            esac
            RIPETI=3
            ;;
        0)  # si ritorna al controlmenu
            echo "Ritorno ..."
            RIPETI=99
            ;;
        *)  # altri caratteri:  RETURN to main menu
            echo
            echo "Invalid choice, returning to main menu ..."
            sleep 3
            RIPETI=98
            ;;
      esac
    done
  #
}
#
##########################################################################
###################################### Functions for node apps management
#
##########################################################################     *** DA AGGIORNARE ***
# Verifica esistenza applicazione in nodedata
#     <-- se esiste il file *.tar.gz si presume che l'applicazione esista
#         <-- si va avanti senza altre azioni
#             <-- si presume che prima sia andato tutto bene ...
#       <-- se il file *.tar.gz non c'e' si prova a scaricare il file da github
#           <-- se si trova il .tar.gz, questo viene espanso senza alcun avviso ...
#     <-- si verifica se esite il .../sysdata/nodedata/*/config.json
#         <-- se esite si esce positivamente:  ITEXISTS = 1
#         <-- altrimenti si esce con errore:   ITEXISTS = 0
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
      # sudo tar xpf $FILEGZ -v --show-transformed -C $3     <-- preserva permission & ownership
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
      # sudo tar xpf $FILEGZ -v --show-transformed -C $3     <-- preserva permission & ownership
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
#
##########################################################################
startstd() {
  ######  Start "standard system"    <--  === start BASE
  echo
  echo "Start gothings BASE subsystem"
  startbase
  sleep 5
}
#
#
###############################
#    Main Logic execution     #
###############################
#
############################################################### MAIN LOGIC
##########################################################################
echo
echo "Verify GOTHINGS installation ..."
#
echo "verify install script ..."
getgitfile "ginit" "gothings-install/master/" "" "EXEC"
if [ "$ITEXISTS" -ne 1 ]; then    # SI INTERROMPE TUTTO se il file non esiste
  stopmenu "${FILEBASEGZ}"  "file ${FILEBASEGZ} is essential for control menu"
  MENUTRAP=66                     # interrommpere il menu principale
  RISULTATO=66
else
  echo "exec ginit install script ..."
  ./ginit "I" # chiamata di verifica iniziale
  RISULTATO=$?
fi
if [ "${RISULTATO}" -ne 0 ]; then
  echo
  if [ "${RISULTATO}" -eq 127 ]; then
      echo "Cannot find the ginit install script"
  elif [ ${RISULTATO} -eq 126 ]; then
    echo
    echo "ginit install script is not executable"
  elif [ ${RISULTATO} -eq 66 ]; then  # Errore FATALE, esci
    echo
    echo -e "${RED} BASE environment is an essential part of GOTHINGS ${STD}"
  fi
  echo
  MENUTRAP=66
else
  echo
  echo "    ./g : Installation OK"
fi
#
# CONTINUE to the menu functions
#
#sleep 3
#
##########################################################################
# function to display menus
show_menus() {
  clear
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo
  echo "    G O T H I N G S   C O N T R O L   MENU"
  echo
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ${VERSION}"
  echo
  echo "1. SHOW      container's status"
  echo "2. START     standard system"
  echo "3. BASE      manage gothings base containers"
  echo "4. VUEDEV    manage reactive VUE containers"
  echo "5. NODE      manage node js development containers"
  echo "6. PYTHON    manage python/flask development containers"
  echo "7. USER      manage user containers"
  echo "8. UPDATE    this menu"
  echo "0. EXIT      return to console"
}
#
# read input from the keyboard and take a action
# invoke the function according to the entered number
read_options(){
	local choice
  read -rsp $'Enter choice [ 1..8 or ^C to exit ] ' -n 1 choice
	case $choice in
		1) showcontainers;;
    2) startstd;;
		3) gothingsbase;;
		4) gothingsvuedev;;
		5) boh;;
		6) boh;;
		7) boh;;
		8) updategmenu;;
    0) consoleexit;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
  ############# Vecchi sottomenu' da aggiornare - vedi:  g.v0.00.05.2019-11-06
  #
  #  1)  gothingsinstall 
  #  3)  nodedev;;
  #  6)  userdir;;
  #
  ##############################
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
  if [[ ${MENUTRAP} -eq 67 ]]
  then
    echo "------------------------------------------------------"
    echo "GOTHINGS Control Menu was downloaded from github,"
    echo "You can re-execute it by typing './g' at the console"
    echo "------------------------------------------------------"
    echo
    break  #-- stop menu
  fi
  if [[ ${MENUTRAP} -eq 66 ]]
  then
    echo 
    echo "----------------------------------------------------------------"
    echo " Are you sure that all necessary software was correctly loaded ?"
    echo
    echo " Please verify content of all JSON configuration files"
    echo
    echo " Please note that a working internet connection is needed to"
    echo " dinamically update software during the first istallation and"
    echo " during updates"
    echo "----------------------------------------------------------------"
    echo
    break  #-- stop menu
  fi
	show_menus
	read_options
done
echo
echo "Shell terminated."
echo
#