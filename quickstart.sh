#!/bin/bash
#                                                                    2021-11-10
                                                                 Version="1.21"
#  Try to find the raspberrypi using ping
#
#  Nota storica
#  Versione soddisfacente nella esecuzione dei test per trovare IP address
#  Da estendere considerando i tentativi test-ssh-0x
#
##########################################################################
##########################################################################
#                                                           user functions
#
Red='\033[0;41;30m'
Std='\033[0;0;39m'
redline(){
echo -e "${Red} $1 ${Std}"
}
#
pause(){
#
#  ask key before continuing (^C is active)
#    $key:  user input key
#
echo '--------------------------------------------------------------
Please, click the script STOP button to stop processing ...'
  read -rsp $'... or press the keyboard Enter key to continue ...' -n 1 key
}
#
continue(){
#  ask for user consense or stop processing
#   Y   continue
#   *   stop processing
#
  read -rsp "Do you like to Continue ? [y/N] " -n 1 key
  case "$key" in
    [yY]) 
      echo
      echo "OK, let's go on"
      echo
      ;;
    *)
      echo
      echo "It is not 'y' or 'Y', so I exit"
      exit
      ;;
  esac
}
#
dots(){
# wait $1 seconds, printing dots on the screen
#   $1 :  # of seconds to wait
  local param1
  printf -v param1 '%d\n' $1 2>/dev/null # converti in intero con tutti i controlli
  while [ $param1 -gt 0 ]
  do
    echo -n "."
    sleep 0.5
    echo -n "."
    sleep 0.5
    let "--param1"
  done
}
#
ipfilter() {
#  elimina il caso localhost (mette RaspiIp="")
#    <-- Ip == 127.0.0.1*    IP non valido
if [[ "$RaspiIp" == 127.0.0.1* ]]
then
  RaspiIp=""
  Stat=0
else
  #  RaspiIP invariato
  Stat=1
fi
}
#
# ref.: https://www.linuxjournal.com/content/validating-ip-address-bash-script
# Slightly modified to:
#     truncate trailing text
#     define & modify the var IpValid
#
# Test an IP address for validity:
# Usage:
#      valid_ip IP_ADDRESS
#   returns:
#      IpValid == <valid IP address>    if check OK
#   OR
#      IpValid == ""                    if IP address is NOT valid
#
function valid_ip()
{
    local  ip=$1
    local  stat=1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    if [[ $stat -eq 0 ]]
    then
      IpValid="${ip[0]}"".${ip[1]}"".${ip[2]}"".${ip[3]}"
    else
      IpValid=""
    fi
    return $stat
}
performtest() {
###############################
#  Perform a single test
#  In:
#      $Test                  <-- name of the test
#      $Method                <-- test to be performed
#  Out:  
#      valid IP address found -->   RaspiIp=<IP adddress>
#      no valid IP found      -->   RaspiIp=""
#  Note:
#      127.0.0.1 (localhost) is NOT considered a valid address
#
###############################
  echo
  echo "$Test"
  RaspiIp=$(eval $Method)
  valid_ip $RaspiIp
  ipfilter
  echo -n "Result: "
  if [[ "$RaspiIp" == "" ]]; then
    echo "RaspiIp KO"
  else
    echo "RaspiIp: $RaspiIp"
  fi
}
#
############################################################################
#
source /app/scripts/include/LocalNames.sh
#
# avviso iniziale
echo -n '---------------------------------------------------- Raspberry Pi quick start '
echo "$Version"
redline "Please note:"
echo '
The board should be powered for a few minutes before executing this process,
until it shows very low activity for at least 10 seconds.
If the board is first-time powered, time needed ranges from one minute to several minutes. 
  (my Pi Zero with a good network connection: ~ 3 minutes)
'
echo 'Please note also:
You should press the '\''y'\'' or '\''Y'\'', followed by the '\''Enter'\'' key when this script asks you if you like to continue.
'
redline "What does this script do?"
echo 'This script try to locate a new Raspberry (C) board on your LAN using default password and hostname.

'
redline "please STOP and execute again if you have to change hostname or password"
echo
continue

# 2.o avviso
echo '
This process is not foolproof.
Anyway, getting a possible address I will test if it the raspi is live and, eventually,
I will try to connect via ssh'

#############################  DA FARE
# mettiamo primo il ping che funziona
#   secondo il getent che funziona
#     terzo l'altro getent
#       poi il ping che non funziona
######################################

# Start tests
Test="Test 1"
echo
echo "$Test"
Method="getent hosts raspberrypi.local | sed -e \"s/ .*//\""
  echo "Method: $Method"
RaspiIp=$(eval $Method)
  Result=$?
  echo "eval Method - Result: $Result - RaspiIp: $RaspiIp"
valid_ip $RaspiIp
  Result=$?
  echo "valid_ip - Result: $Result - IpValid: $IpValid"
ipfilter
  echo "ipfilter - RaspiIp: $RaspiIp - Stat: $Stat"
echo -n "Result: "
if [[ "$RaspiIp" == "" ]]
then
  echo "RaspiIp KO"
else
  echo "RaspiIp: $RaspiIp"
fi 
# *** Fine Test  ***
  # Delete test:
  RaspiIp=""
  echo "Delete the IP address, to cancel $Test"

Test="Test 2"
if [[ "$RaspiIp" == "" ]]
then
  echo
  echo "$Test"
  Method="getent hosts raspberrypi | sed -e \"s/ .*//\""
  RaspiIp=$(eval $Method)
  valid_ip $RaspiIp
  ipfilter
  echo -n "Result: "
  if [[ "$RaspiIp" == "" ]]
  then
    echo "RaspiIp KO"
  else
    echo "RaspiIp: $RaspiIp"
  fi 
else
  echo
  echo "$Test skipped"
fi
# *** Fine Test ***
  # Delete test:
  RaspiIp=""
  echo "Delete the IP address, to cancel $Test"

Test="Test 3"
if [[ "$RaspiIp" == "" ]]
then
  echo
  echo "$Test"
  Method="ping -q -c 3 -t 1 raspberrypi.local | grep PING | sed -e \"s/).*//\" | sed -e \"s/.*(//\""
  RaspiIp=$(eval $Method)
  valid_ip $RaspiIp
  ipfilter
  echo -n "Result:"
  if [[ "$RaspiIp" == "" ]]
  then
    echo "RaspiIp KO"
  else
    echo "RaspiIp: $RaspiIp"
  fi 
else
  echo
  echo "$Test skipped"
fi
# *** Fine Test ***
  # Delete test:
  RaspiIp=""
  echo "Delete the IP address, to cancel $Test"

Test="Test 4"
if [[ "$RaspiIp" == "" ]]
then
  Method="ping -q -c 3 -t 1 raspberrypi | grep PING | sed -e \"s/).*//\" | sed -e \"s/.*(//\""
  performtest
fi
# *** Fine Test ***
  # Delete test:
  RaspiIp=""
  echo "Delete the IP address, to cancel $Test"

#
if [[ "$RaspiIp" == "" ]]
then
  Test="Test 5"
  IP='192.168.123.123'
  Method="echo $IP"
  performtest
  echo "This is a simulation, used during development only"
  echo "It give us the IP $IP which is very improbable"
  echo "The following will thus give a 'raspi not found' error"
  echo '
*** DA TOGLIERE in produzione ***
'
fi
# *** Fine Test ***


# Selezioniamo un IP
RaspiIp="192.168.1.43"
#
#  test SSH
if [[ ! "$RaspiIp" == "" ]]
then
# Abbiamo un IP ... contattiamo la scheda
#
  Test='SSH'
  # abbiamo trovato almeno un probabile IP
  # qui possiamo guardare se SSH funziona
echo
echo "Comandi necessari:"
echo -n "expect:  "
echo $(which expect)
echo -n "sshpass:  "
echo $(which sshpass)

echo '
echo "Tentativo SSH automatico"

'
echo "Chiamo la raspi con IP address $raspiIp ..."

#direttamente dall'esempio ...
/app/scripts/sshexpect.sh pi "192.168.1.43" "raspi2019"



echo '<-- raspi ends'

  # 1 == va bene
  OK=1 
  # 0 == va male
  #OK=0
fi
# fine 

exit


echo
if [[ "$OK" -gt 0 ]];then
# Caso: SSH ha funzionato
 echo 'SSH e'\'' riuscito a contattare la scheda ...

***** seguito ancora da fare, ora esco ...'
  echo "e' andata bene!"
  exit ######## Uscita finale in caso positivo
else
# Caso: SSH NON ha funzionato
 echo 'SSH NON e'\'' riuscito a contattare la scheda ...
'
  echo "Sorry, non e' andata!"
  echo "Ultima prova tentata: $Test"
  echo
  echo "***** Mettiamo qui un help per il caso negativo ..."
  echo "Ho finito !!!"
fi


exit ######## uscita finale in caso negativo

### FINE
echo '
*** ROBA VARIA da controllare
# get & verify IP

The system give us the standard loopback address
The raspi is unreachable
Please verify it is still powered
It may also have a non standard name for whatever reason

*** There are are several other reason possible ! ***
You may look at the GoThings site:
  https://www.gothings.org/raspi-init-help
or google: how to find IP address Raspberry

'

