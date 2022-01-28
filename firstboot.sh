#!/bin/bash
#                                                                    2022-01-09
#
#
################################################################################
#                                                               log script start
#  Inizializzazione della raspberry:
#    - start ssh
#    - init wifi & wpa_supplicant.conf
#    - download & start app_boot
#        <-- run_once.tar.gz: app (di gestione) da installare sulla raspberry
#        <--     run_once.sh: script di lancio di app_boot
#
#  In sostanza:
#    firstboot.sh    lavoro iniziale comune a tutti, ovvero SSH & wifi
#    app_boot        app per il lavoro 'vero', da personalizzare
#                    (abbiamo semplificato la parte comune a tutti)
#
################################################################################
#                                                     drop privileges to user pi
#  ref:  https://stackoverflow.com/a/29969243
if [ $UID -eq 0 ]; then
  cd "/home/pi"
  exec su pi "$0" -- "$@"
fi
#
################################################################################
#                                                                   init logfile
cd /home/pi
LogFile="/home/pi/firstboot.sh.log"
echo "`date` firstboot.sh start" > "${LogFile}"
#
################################################################################
#                                                                 Funzioni utili
#------------
log() {
#  $1   stringa da scrivere su firstboot.sh.log
  echo $1 >> "${LogFile}"
}
#------------
errorstop() {
#  $1   codice di errore
#  $2   stringa di errore
#  $3   label chiamante (per sapere dove ...)
  if [ $1 -gt 0 ]
  then
    echo "$3 | error $1 - $2" >> "$HOME/firstboot.sh.log"
    echo "`date` firstboot.sh end" >> "$HOME/firstboot.sh.log"
    exit
  else
    echo "$3 | passed" >> "$HOME/firstboot.sh.log"
  fi
}
#
#---------
setdir() {
#  $1  verifica esistenza dir
#        <-- crea dir se non esiste
  local Result
  if [ ! -d "$1" ]; then
    mkdir "$1"
    Result=$?
    errorstop ${Result} "set dir $1 non riuscito"  "set dir $1"
  fi
}
#
################################################################################
#                                              verifica - togliere in produzione
log "user: $(whoami)"
cd "$HOME"
log "Home content:"
ls -la >> "${LogFile}"
#
################################################################################
#                                              expand and activate raspi-manager
#
# expand
tar xpf /boot/raspi-manager.tar.gz -C "/home/pi"
Result=$?
errorstop ${Result} "Error expanding raspi-manager"  "Expand raspi-manager"
#
# verify directories
PiHome="/home/pi"
Dockrepo="${PiHome}/dockrepo"
setdir "${Dockrepo}"
Result=$?
errorstop ${Result} "Error on ${Dockrepo} dir"  "Dir ${Dockrepo}"
InstallDir="${Dockrepo}/raspi-manager"
setdir "${InstallDir}"
Result=$?
errorstop ${Result} "Error on ${InstallDir} dir"  "Dir ${InstallDir}"
cd "${InstallDir}"
Result=$?
errorstop ${Result} "Error on ${InstallDir} cd"  "cd ${InstallDir}"
#
# list raspi-manager dir
ls -la >> $LogFile
Result=$?
errorstop ${Result} "Error while listing ${InstallDir}"  "${InstallDir} content"
#
# activate python environment
# source ./bin/activate
# Result=$?
# errorstop ${Result} "Error activating python environment"  "Activate python environment"
#
# install requirements
# pip install -r requirements.txt
# Result=$?
# errorstop ${Result} "Error installing requirements"  "install requirements"
#
################################################################################
#                                                              run raspi-manager
# python launcher.py &
# Result=$?
# errorstop ${Result} "Error running raspi-manager"  "raspi-manager run"
#
################################################################################
#                                                                       In prova

log "Versione di prova ---------------------------"
log "pwd: (pwd)" >> $LogFile
sleep 3
ps awx | grep "launcher" >> $LogFile

#
################################################################################
#                                                                 log script end
echo "`date` firstboot.sh end" >> $LogFile
#