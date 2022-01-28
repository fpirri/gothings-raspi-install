#!/bin/bash
#                                                                    2022-01-09
                                                                 Version="02.00"
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
echo "`date` firstboot.sh ver. $Version starts" > "${LogFile}"
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
    exit $1
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
#                                                             verify directories
PiHome="/home/pi"
Dockrepo="${PiHome}/dockrepo"
setdir "${Dockrepo}"
Result=$?
errorstop ${Result} "Error on ${Dockrepo} dir"  "Dir ${Dockrepo}"
InstallDir="${Dockrepo}/raspi-install"
setdir "${InstallDir}"
Result=$?
errorstop ${Result} "Error on ${InstallDir} dir"  "Dir ${InstallDir}"
cd "${InstallDir}"
Result=$?
errorstop ${Result} "Error on ${InstallDir} cd"  "cd ${InstallDir}"
#
# list raspi-install dir
ls -la >> $LogFile
Result=$?
errorstop ${Result} "Error while listing ${InstallDir}"  "${InstallDir} content"
#
################################################################################
#                                                           activate run_once.sh
cp /boot/run_once.sh ./
Result=$?
errorstop ${Result} "Copy error: run_once script" "copy run_once script"
cp /boot/run_once.tar.gz ./
Result=$?
errorstop ${Result} "Copy error: run_once archive" "copy run_once archive"
bash run_once.sh
Result=$?
errorstop ${Result} "Error from run_once script" "exec run_once script"
#
################################################################################
#                                                                       In prova

log "Versione di prova ---------------------------"
log "Working dir:"
pwd >> $LogFile

#
################################################################################
#                                                                 log script end
echo "`date` firstboot.sh ver. $Version end" >> $LogFile
#