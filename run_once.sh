#!/bin/bash
#                                                                    2022-01-09
                                                                 Version="02.00"
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
log "$InstallDir content:"
ls -la >> "${LogFile}"
#
################################################################################
#                                                                         avviso
Archive="run_once.tar.gz"
log "Espandi l'archivio $Archive"
tar xzvf "$Archive" -C $HOME
Result=$?
errorstop ${Result} "Error expanding $Archive"  "expanding $Archive"

WorkDir="${HOME}/dockrepo/raspi-manager"
cd "$WorkDir"
Result=$?
errorstop ${Result} "Cannot cd into $WorkDir"  "cd $WorkDir"
log "$WorkDir content:"
ls -la >> "${LogFile}"

log "Next step: Install raspi manager"

log "now in raspi manager dir"

#                                                                               SONO QUI
exit 111

#
################################################################################
#
################################################################################
#                                                                         avviso
#                                          download latest manager da repository
#
wget -O ${HOME}/managerdirs.tar.gz https://github.com/fpirri/gothings-raspi-manager/raw/main/managerdirs.tar.gz
#
#
################################################################################
#                                                             expand in dockrepo
#
tar xpf "${HOME}/managerdirs.tar.gz" -C "${HOME}"
Result=$?
errorstop ${Result} "expand managerdirs.tar.gz error"  "Get managerdirs.tar.gz"
#
################################################################################
#                                                               Lancia il server
cd "${HOME}/dockrepo/raspi-manager"
echo "provo a lanciare lo script-server ..."
pip install -r requirements.txt
Result=$?
errorstop ${Result} "pip error in requirements.txt"  "pip requirements"

python3 launcher.py
Result=$?
errorstop ${Result} "error in launcher.py"  "launch script server"

exit
#*************************** Versione di prova end


################################################################################
#                                                                installa sul PC
#
./dockrepo/raspi-manager/install_raspi_manager
Result=$?
errorstop ${Result} "install raspi-manager error"  "Install raspi-manager"
#
################################################################################
#                                                                Avvisa l'utente
#
echo
echo "No errors?"
echo
echo "Congratulations! You have installed your PC Manager"
echo
echo "Open a browser in this PC and go to the site:"
echo "  localhost:5000"
echo
echo "You may like to try the script 'Ping your raspi'"
echo
echo "Please have a look at the documentation at 'www.gothings.org'"
echo
