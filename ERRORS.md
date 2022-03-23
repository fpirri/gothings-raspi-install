# Raspi Install Errors

While installing firstboot application into your raspberry board you may encounter a number of errors ...
<br />



ADVICE:
----

**The Raspi Install project is under construction.**  

This is the first edition of possible errors. It may be corrected after the beta test.

Please read the <link to README.md> for more information  
<br/>

----

### Logs

A log of the install process is available at the location:
    ~/dockrepo/raspi-install/log/raspi-install.log
in the machine running the script.

After the reboot the raspi will contain logs in the home directory:
xxx
 < - - from the firstboot script
yyy
 < - - from the run_once script


<br />
### Errors


Q-101
  Error <xx> while verifying log directory: <Dir name>"
  This should not happen!"
  Eventually, please report to the developers: Q-101
  Section: quickstart
A log dir should exist at this moment, but it is not found. Something is not as it should be. The user should be able to define a directory, but it could not.

Q-102
  Error <xx> while setting working directory to ~/dockrepo/sysdata/raspi-install"
  This should not happen!"
  Eventually, please report to the developers: Q-102"
  Section: quickstart
The user should be able to define a working directory, but it could not. Something is not as it should be.    

Q-103
  Error $Result while setting working directory to ~/dockrepo/sysdata/raspi-install
  This should not happen!
  Eventually, please report to the developers: Q-103
  Section: quickstart
Same as Q-102.

  Q-104
  The Raspberry (C) board is not available at address <RaspiIp>
  ERROR Q-104 with Result: <xx>
  Section: quickstart
No board responds to an SSH connection request.
Please verify the raspi is alive. You can also try a manual connection from a terminal.
This script will find an IP address only after the network has somehow found activity on this address. Normally, it is your board activity. Please note it may happened a while ago.

  Q105
  The file transfer to the Raspberry (C) board failed
  ERROR Q-105 with Result: <xx>
  Section: quickstart
 Shortly before this error the board exchanged data with this script, so network communication should be OK.
You should have encountered some error above. Please verify.
You can also try a manual connection to the board, such as:
   ssh pi@<Board IP address>
Use 'raspberry' at the password request.
If this fails, you have a strong hint at what happened.
Otherwise, you can try:'
    scp -r ~/dockrepo/sysdata/raspi-install/raspi1stboot pi@<board IP address>:/home/pi
which is the same statement issued by this script. The board response should evidence the error cause.



  Q-106
  Cannot set firstboot service
  ERROR Q-106 with Result: <xx>
  Section: quickstart
The script attempted a few operation to make firstboot service operational.
You should find above some error. Please verify.



  Q-107
  Cannot set firstboot service
  ERROR Q-107 with Result: 
  Section: quickstart
Errors found while performing the final control on the board.
You should find above some error. Please verify.



  Q-131
  Expect program not installed
  ERROR Q-131 with Result: 
  Section: quickstart
This script tries to install expect script automatically, but failed.
You should try to install expect manually.



  Q-155
  Cannot set firstboot service
  ERROR Q-155 with Result: 
  Section: quickstart
The script could not find the board.  
You may find above some error. Please verify.
If there are no errors it means the board is not registered on the LAN / WiFi network.
The probable cause could be a wrong OS configuration. Please google:
  Find Raspberry PI address on local network
and try to find the IP address manually.
After a successful search you may retry this script.
Remember: after power up the board' led shows activity for a while. 
You should wait until led is stable for several seconds.
For my raspi zeroW it is up to a few minutes.



  Q-156
  User pressed ^C
  ERROR Q-156 with Result: 
  Section: quickstart
The user choosed to stop processing.



   S-121 to S-127
   Timeouts while expecting some result
    Section: sshexpect
   Some operation timed out waiting a result from board. 
   If the final advice is:
       The raspi is prepared, let's go on ...
   all ended OK, otherwise the error is written above



  S-132, S-133
     Fatal timeout while transferring files to the raspi.
     Section: scpfile
  The above contains the transferred files and the timeout cause



  S-141 to S-147
   Fatal timeouts while moving files to the final location into the raspi.
   Section: sshmove
 The above contains the the timeout cause



  S-151 to S-154
  Fatal timeouts while verifying needed files, directory and links exist.
   Section: sshverify
 The above contains missing item(s) and the timeout cause






<br />
---------------------------

# DISCLAIMER

As commonplace in github, the project may include other work which may have different licensing terms.  
The author make his best to note usability and provenience of every work included here.  
A list of the software that inspired this work is reported in the [ACKNOWLEDGEMENT](https://github.com/fpirri/gothings-raspi-install/blob/master/ACKNOWLEDGEMENT.md) section.  
<br/>

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Please consult the [LICENSE](https://github.com/fpirri/gothings-raspi-install/blob/master/LICENSE) section.
