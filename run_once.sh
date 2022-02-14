#!/bin/bash
#                                                                    2022-01-09
                                                                 Version="02.01"
#
#    run_once installation file
#
#    Scopo: personalizzare la raspi per una applicazione specifica
#
#    La versione iniziale installera' il raspi-manager
#    (ovvero lo script server di bugi)
#
#  @@@@@ per ora: NIENTE !!!
#
#  @@@@@   in caso di errore, questo va segnalato a firstboot
#  @@@@@   in modo che si veda bene che manager-boot ha fallito
#
#######
################################################################################
#                                                               log script start
LogFile="$HOME/dockrepo/raspi-install/run_once.sh.log"
echo "-----> `date` run_once ver. $Version starts" > "${LogFile}"
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
    echo "$3 | error $1 - $2" >> "${LogFile}"
    echo "`date` firstboot.sh end" >> "${LogFile}"
    exit
  else
    echo "$3 | passed" >> "${LogFile}"
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
#                                        verifica - aggiornare per la produzione
log "user: $(whoami)"
InstallDir="${HOME}/dockrepo/raspi-install"
cd "$InstallDir"
Result=$?
errorstop ${Result} "Error: $InstallDir not active"  "cd $InstallDir"
#
################################################################################
#                                                        eliminare in produzione
log "$InstallDir content:"
ls -la >> "${LogFile}"
#
################################################################################
#                                              espansione archivio raspi-manager
Archive="run_once.tar.gz"
log "Espandi l'archivio $Archive"
tar xzvf "$Archive" -C $HOME
Result=$?
errorstop ${Result} "Error expanding $Archive"  "expanding $Archive"
WorkDir="${HOME}/dockrepo/raspi-manager"
cd "$WorkDir"
Result=$?
errorstop ${Result} "Cannot cd into $WorkDir"  "cd $WorkDir"
#
################################################################################
#                                                          install raspi manager
#                                                   aggiornare per la produzione
log "$WorkDir content:"
ls -la >> "${LogFile}"
log "now in raspi manager dir"

log "ToDo: Install required programs"
log "venv:"
sudo apt install -y python3-venv  >> "${LogFile}"
Result=$?
errorstop ${Result} "Error installing python3-venv"  "Install python3-venv"

log "pip3"
sudo apt install -y python3-pip >> "${LogFile}"
Result=$?
errorstop ${Result} "Error installing python3-pip"  "Install python3-pip (pip3)"

log "install requirements"
pip3 install -r requirements.txt >> "${LogFile}"
Result=$?
errorstop ${Result} "Error installing requirements"  "Install requirements"


log "launch script server"
python3 launcher.py &
Result=$?
errorstop ${Result} "error launching script server"  "script server launch"

#
################################################################################
#                                                                       In prova

log "Versione di prova ---------------------------"
log "Working dir:"
pwd >> $LogFile

#
################################################################################
#                                                                 log script end
echo "`date` run_once.sh ver. $Version ends" >> $LogFile
#
#*************************** Versione di prova end

