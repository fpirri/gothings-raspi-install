# GoThings Raspi Install
Raspberry &copy; boards bootstrap installer

1st step to customized installations using just your browser.  
<br />

ADVICE:
----  

**This project is under construction.**  

This version is being adjusted. This notice will be removed after the update is completed.

This project is now subjected to a major revision.
As such, the documentation is currently somewhat inconsistent with the actual operation of the installer.

This work was done by leveraging the work of open source authors. The recognition of these sources is made with links to the various works and, above all, in the  [ACKNOWLEDGEMENT](https://github.com/fpirri/gothings-raspi-install/blob/master/ACKNOWLEDGEMENT.md) section.  
The original work included can be used according to the permissible MIT License.  

Please goto the  [ACKNOWLEDGEMENT](https://github.com/fpirri/gothings-raspi-install/blob/master/ACKNOWLEDGEMENT.md) page for a list of the external software used here.  
Please read the [disclaimer](#disclaimer) for more information.  

<br/>

----
[What GoThings Raspi Install does](#what-gothings-raspi-install-does)  
[What you get](#what-you-get)  
[What you need](#what-you-need)  
[Pre-installation steps](#pre-installation-steps)  
[Raspi install](#raspi-install)  
[Disclaimer & Licensing](#disclaimer)  

----

<br />

What GoThings Raspi Install does
----  

- Raspi-Install is simply a bootstrap application, i.e. it installs a bigger application, then it hides itself until called again by the user.  
- The default version installs the GoThings Raspi Manager <insert-link>;  
- The user can easily bootstrap other application customizing the run_once script only

NOTE: This bootstrap was made for the ***GoThings System***, which is an ensemble of cloud and embedded applications described here](https://www.gothings.org)  

<br />  

What you get  
----  

Final result of the bootstrap process is an application installed on your raspi at next boot.  
The default application is an HTTP server which allows you to run bash scripts using a standard browser in the same LAN of your raspi board.  
This is obtained bringing together three systems: the raspbian operating system, the raspberian-firstboot service and the bugy-script-server
Please find further details at <link-da-fare>;  
The procedure is customizable, so the user can use the same process to install whatever application just by changing a run_once script.  

<br />  

What you need
----  

* a Raspberry &copy; board
    * the procedure should work for every board supported by the raspbian OS you choose  
    * anyway, it is tested on P1B+ and Zero W boards only
* an sd-card to store the raspbian OS and a few scripts  
* an internet connection to download the OS and the raspi-install  
* you have to follow the [PRE-INSTALLATION](#pre-installation-steps) procedure documented below   

Finally, please follow the instructions in the [INSTALLATION](#gothings-installation) section below

<br />  

------------------------------

<br/>

## Pre-installation steps

The goal of the pre-installation is to have an sd card containing a standard version of the raspbian operating system.  
I will not try to outsmart what you can find in iternet about this goal.
You may google something like 'raspberry pi os installation guide' to obtains valuable informations.
Among the top you find documentation [from the manufacturer](https://www.raspberrypi.com/documentation/computers/getting-started.html) 
containing the detailed instructions to use the Raspberry pi imager.   
Many others pages and videos are available.
Personally, I used the search 'raspberry pi headless setup wifi' to find how to setup my Pi ZeroW.
I found this extremely useful to start working with network only connection which really is the only thing you need to have an SSH connection to your board. 
In fact, the procedure can be used for every raspi board.
At the next boot the board will connect to internet and initialize itself without asking anything to you.
Main advantage of Raspberry Pi Imager is you can setup SSH access and wifi LAN connection just filling 
some [advanced options](https://www.raspberrypi.com/documentation/computers/getting-started.html#using-raspberry-pi-imager)   
The imager source is on [github](https://github.com/raspberrypi/imagewriter)
You may find interesting information on to the advanced options [here](https://www.tomshardware.com/news/raspberry-pi-imager-now-comes-with-advanced-options)  

The imager only option for storage is an SD card. I prefer to have a personalized .img file on my PC to skip the Pi Imager step next time.
The google search 'create image file from sd card' offers ways for windows, mac and linux system.

Final result of the pre-installationc step is an SD card ready to be inserted into the raspberry board.

<br />

-------------------------------

<br />

# Raspi Install

You should now have a raspi board with an SD card containing a raspbian OS which will connect to your network through wifi or LAN.
The requisite for raspi-install is to have an SSH connection to automate the use of the bootstrap process.

The raspi board should be powered for a few minutes before executing this
process, until it shows very low activity for at least 10 seconds.
If the board is first-time powered, time needed may range from one minute to
several minutes.  
(my Pi Zero with a good network connection: ~ 3 minutes)   

#### Quickstart
The fast (and dirty) way to go is to download a bash script from github and execute it in any directory of your choice:  
wget -O ./raspiinit https://github.com/fpirri/gothings-install/raw/master/raspiinit && bash raspiinit   
Please note you need a linux system for this. Any raspi board can be used.

***ADVICE***
security of such an action is **absolutely bad**
The secure way is to download the script, verify its actions and eventually go on only after you find it secure.

The script will describe its own action while executing.    
It will ask you several times if you like to continue. The pause may be useful to get a feeling of the script operations.   
It is also useful during the beta-test now on course, to report errors to the developer (if you like).

You can post a comment on the [GoThings homepage](https://www.gothings.org)   
I will be grateful for your eventual suggestions to enhance the script in any way.

When the script ask if you like to continue, press any single key in your
keyboard to continue.
If you press ^C, that is both the ctrl key and 'C', the process will STOP

Script operations are detailed on this [GoThings page](https://www.gothings.org/raspberry-gothings/raspi-install/) 
The main point to note is that it creates the directories ~/dockrepo/raspi-install/ and ~/dockrepo/sysdata/ in your user home.
If you don't like it I suggest you use another raspberry board to control this script.


The procedure should function on an already used sd card, i.e. the next boot 

<br />

#### 1- Raspi first boot
Connect to your board via ssh, commands below should be gived in the home directory /home/pi

#### 2- Download and launch the 'raspiinit' script
Exec the command:

      wget -O /home/pi/0 https://raw.githubusercontent.com/fpirri/gothings-raspi-install/master/0

#### 3- Follow the screen
Exec the command:


#### 4- Reboot?

If the script ends with no errors you may choose to powerdown


#### 5- Go

Last action dowload the  go-raspi control script from github. It also allow you to exec the menu by typing './go-raspi' in the /home/pi/ directory.   


----------------------

<br /><hr />


<br />

# DISCLAIMER
As commonplace in github, the project include other work which may have different licensing terms.  
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
