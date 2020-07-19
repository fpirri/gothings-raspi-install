# GoThings Raspi Install
How to install Raspbian and docker on a Raspberry board  
  
Get containerized HTTP server, node js, python and more on your raspi !  
<br />

ADVICE:
----  

**This project is under construction.**  

Project documentation is sparse and not reliable, owing to the on-going (re-)definition of many secondary aspects of the project.  
Owing to the above, please be aware it may be next-to-impossible to use this repository to make any useful work.  

Anyway, the original work included may be used according to the permissible MIT License.  

Please read the [disclaimer](#disclaimer) for more information  
<br/>

----
[What GoThings Raspi Install does](#what-gothings-raspi-install-does)  
[What you get](#what-you-get)  
[What you need](#what-you-need)  
[GoThings System short description](#gothings-system-short-description)  
[Pre-installation steps](#pre-installation-steps)  
[GoThings installation](#gothings-installation)  

[Disclaimer & Licensing](#disclaimer)  

----

<br />

What GoThings Raspi Install does
----  

* Lets you click/perform a sequence of actions to install docker on your raspberry pi board
* ***GoThings Raspi Install*** allows you to set locales, get some data from github and initialize the ***GoThings System***
* It runs a demo application
* It also install and execute the ***GoThings Control Menu*** on the board  
  
  
 ***GoThings Control Menu*** allows you to manage lifecycle of your containers
   
 ***GoThings System*** is an ensemble of cloud and embedded applications briefly described [below](#gothings-system-short-description")  
 
<br />  

What you get  
----  

   - docker installed in your raspberry pi (P1 & Pi Zero)
   - nginx running in your board as an HTTPS gateway to the external world
   - a basic HTTP service on-board
   - a NODE JS demo application you can modify
   - the ***GoThings Control Menu*** to manage your GoThings System

Through **GoThings Control Menu** you manage the lifecycle of all containers and user data in the *GoThingsSystem*

After that you may write your programs using javascript, python or PHP languages. They will each run in its own container.  

Please note the docker installation is a standard one. The *GoThings System* configuration data is made up from a few files and you may delete them and use docker for any other purpose.
  
<br />  

What you need
----  
  
* a raspberry P1-B+ or PI Zero W board
    * the procedure may work for other Raspberry board models
    * anyway, it is tested on P1B+ and Zero W boards only
* an sd-card to store the raspbian OS  
* an internet connection (you will download several big files)
    * you can download the OS from:  
          https://downloads.raspberrypi.org/raspbian_lite/images/  
        
* you have to follow the [PRE-INSTALLATION](#pre-installation-steps) procedure documented below to run the raspbian system on your raspberry *zero* board  
   
Finally, please follow the instructions in the [INSTALLATION](#gothings-installation) section below
 
<br />  

GoThings System short description  
----  

* The *GoThings System* is made up from a number of co-operating docker containers
* each container does a specific function but all the ensemble is seen from the network as a single entity
    * each container may use a different language, i.e. javascript, python, PHP, ...
* The *GoThings System* is made up from two parts: 'base' & 'user'
* The 'base' part gives to the GoThings System the capabilities common to most applications, such as network access and security  
* The 'user' part is specific to a particular configuration
    * please note: this part allows users to run their own code
* *GoThings* run in your Internet-of-Things, on the ARM achitecture boards such as the Raspberry Pi
* An alpha version of *GoThings* is now running in standard cloud virtual systems (It will be published ASAP [here](https://github.com/fpirri/gothings-cloud))

<br />

In [github raspi-apps](https://github.com/fpirri/gothings-raspi-apps)  you find:
* **GoThings Control Menu** to manage the lifecycle of your containers
* some templates that can be customized for specific purposes
 
<br />  

<br />  
 
### GoThings can be defined as:
##### a Docker Distributed Things Operating System (DDT-OS) running on a number of networked things.
  
GoThings uses nodejs, vuejs and python-flask technologies.  
GoThings networking is based on http protocol and exploits many of the nginx+lua+redis capabilities  
  
  
------------------------------

<br/>

## Pre-installation steps


- Choose your raspbian image.
   - the following instructions use the ***buster lite*** version of raspbian OS from the official rasperry site
   - the first gothings-raspi-install release, archived [here](https://github.com/fpirri/gothings-raspi-install/tree/master/history/version-01), worked with raspbian *stretch lite* version
   - You have to burn your sd-card to use it on the rasperry
   - if you wish to use a different release, please note that docker does not run on every armv6l raspbian image, you have to test it by yourself
 <br/>
 
Please note you have to abilitate SSH access on your raspberry in order to use the *GoThings System*  
To this end you may follow the official instructions or google 'headless raspberry setup' and choose one of the many tutorials.    
I successfully followed this [tutorial](https://styxit.com/2017/03/14/headless-raspberry-setup.html)  
You must also abilitate the wi-fi connection to use the *zero w* raspi model  
  
If it happens you use Linux on your PC, you can download the [setraspiboot](https://raw.githubusercontent.com/fpirri/gothings-raspi-install/master/setraspiboot) script. Point and save the link on your PC and follow the instructions below.  
The script is tested with bash shell on ubuntu, it should run an many other linuxes.  
It may also run on MS Windows 10, *extended* with WSL (**not tested**).  
  
The steps to follow:  
* download the (https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip) raspbian image from the raspberry official site  
    * if you use [balena etcher](https://www.balena.io/etcher/) SD-card burning software you don't need to expand the zip archive  
* burn the *buster* image onto your SD card  
    * at minimum an 8GB card is required  
    * a 16GB or greater is recommended  
* inspect the burned card on your PC  
    * you should find two volumes: *boot* & *rootfs*
    * on ubuntu 18.04 the boot volume path probably is: /media/&lt;username&gt;/boot
    * were &lt;username&gt; is your user name on the PC
* take note of the path of the boot volume
* download the setraspiboot script at https://raw.githubusercontent.com/fpirri/gothings-raspi-install/master/setraspiboot
    * open it in your editor
    * at the top you find 2 variables:  
       SDBOOTDIR  
       WPA_DATA
* update the script content:
   * your boot volume path in SDBOOTDIR
   * your wifi data in  WPA_DATA
   * you may add as many wifi network as you like
* save the script and launch it with the command:  
     source setraspiboot  
    * the script will run in your current environment
* eject the sd-card
* put the new card in the raspberry board and power it up
  
First time you should allow the board to complete OS installation.  
It may take up to a few minutes.  
You should see faint flashes of the LED, periods of darkness and finally the LED stably lit for more than 10 seconds  

At the end you can:
- Connect via ssh from a PC terminal on the same LAN
   - in terminal you can write:  
        ssh pi@raspberrypi.local
        
      normally it automatically find the new board on LAN
   -  If that don't function please try googling 'find your raspberry IP address'  and connect via ssh from terminal:
        
          ssh pi@<your IP address>
          
          
- It is **VERY IMPORTANT** that you change your password to a very strong one ...

    -   **<-- PLEASE FOLLOW** this advice !!!


**You should now have a raspberry PI, reachable via ssh, which can run the GoThings System**
    
<br />

-------------------------------

<br />

# GoThings installation

<br />

#### 1- Connection
Connect to your board via ssh, commands below should be gived in the home directory /home/pi

#### 2- Download the 'zero' script
Exec the command:

      wget -O /home/pi/zero https://raw.githubusercontent.com/fpirri/gothings-install/master/zero

The file *zero* is the primary bootstrap script.  
     
 To give yourself a minimum of security you should inspect the integrity of the files you download from internet.  
 You can inspect the file with the command:  
         nano zero  
please do not change anything and use ctrl-X to exit from the nano editor.  
 
#### 3- exec the zero script
Exec the command:

        source zero

please note: the script runs locally, without the need to mark it as executable

#### 4- Install actions

Follow the procedure suggested by the zero script, one action at a time.  
**It is advisable to exec first and second actions only once.**  
You may execute the following sections multiple times, althought it should not be necessary.  

###### 4.1- Utils

First action set the board as recommended for running docker and docker-compose.  
Locales  GB, IT and US are created.  
Also, the archive zerodirs.tar.gz is downloaded from github and expanded.
This install a number of directories and files that allow to run a simple test and prepare the board for GoThings applications.  

###### 4.2- Install DOCKER

This automates the installing of docker binaries, following the official procedure from [docker](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script)  
Please note that docker documentation affirms it is dangerous to execute this step more than once.

###### 4.3- Install COMPOSE

This step follows this [tutorial](https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl) to install docker-compose.  
This step is a time-consuming one: in my raspi zero w it spent more than an hour to go.

###### 4.4- Test

This section install a web server on your raspi and allow you to browse a few test pages.  
It eventually confirms the whole install process and the network connection.  
You can start browsing loooking at the homepage:  
   http://<your-raspi-ip-address>  

###### 4.5- Go

Last action dowload the  go-raspi control script from github. It also allow you to exec the menu by typing './go-raspi' in the /home/pi/ directory.   


----------------------

<br /><hr />

# Enjoy docker and GoThings !
-----


<br />

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

