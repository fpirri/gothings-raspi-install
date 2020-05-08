# GoThingsInstall

Script to install docker and running example on a Raspberry board  
<br />  

----
DISCLAIMER:  
**This project is under construction.**  

Project documentation may be unreliable, owing to the on-going testing and possible redefinition of some secondary aspects of the project.  
Owing to the above, please be aware it may be difficult to use this repository to make any useful work.  

Anyway, the original work included may be used according to the permissible MIT License.  


<br />  

----
[What GoThingsInstall does](https://github.com/fpirri/gothings-install#what-gothingsinstall-does)  
[What you get](https://github.com/fpirri/gothings-install#what-you-get)  
[What you need](https://github.com/fpirri/gothings-install#what-you-need)  
[GoThingsSystem short description](https://github.com/fpirri/gothings-install#gothingssystem-short-description)  
[Pre-installation steps](https://github.com/fpirri/gothings-install#pre-installation-steps)  
[GoThings installation](https://github.com/fpirri/gothings-install#gothings-installation)  

----

<br />

What GoThingsInstall does
----  

* Lets you click/perform a sequence of actions to install docker on your raspberry pi board*
* ***GoThingsInstall*** allows you to set locales, get some data from github and initialize the ***GoThingsSystem***
* It runs a demo application
* It also install and execute the ***GoThingsControlMenu*** on the board  
  
  
 ***GoThingsControlMenu*** allows you to manage lifecycle of your containers
   
 ***GoThingsSystem*** is briefly described [below](https://github.com/fpirri/gothings-install#gothingssystem-short-description "GoThingsSystem short description")  
 
<br />  

What you get  
----  

   - docker installed in your raspberry pi (P1 & Pi Zero)
   - nginx running in your board as an HTTPS gateway to the external world
   - a basic HTTP service on-board
   - a NODE JS demo application you can modify
   - the ***GoThingsControlMenu*** to manage your GoThingsSystem

Through **GoThingsControlMenu** you manage the lifecycle of all containers and user data in the *GoThingsSystem*

After that you may write your programs using javascript, python or PHP languages. They will each run in its own container.  

Please note the docker installation is a standard one. The *GoThingsSystem* configuration data is made up from a few files and you may delete them and use docker for any other purpose.
  
<br />  

What you need
----  
  
* a raspberry P1-B+ or PI Zero W board
* an sd-card with raspbian-stretch-lite.zip  
     please note you need the 2018-11-13 raspbian version image, available at:

          https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-11-15/2018-11-13-raspbian-stretch-lite.zip
          
* an internet connection (you will download several big files)
* you may have to follow the [PRE-INSTALLATION](https://github.com/fpirri/gothings-install#pre-installation-steps) procedure documented below to run the raspbian system on your raspberry board
 
 Finally, please follow the instructions in the [INSTALLATION](https://github.com/fpirri/gothings-install#gothings-installation) section below
 
<br />  

GoThingsSystem short description  
----  

* The *GoThingsSystem* is made up from a number of co-operating docker containers
* each container does a specific function but all the ensemble is seen from the network as a single entity
    * each container may use a different language, i.e. javascript, python, PHP, ...
* The *GoThingsSystem* is made up from two parts: 'base' & 'user'
* The 'base' part gives to the GoThings System the capabilities common to most applications, such as network access and security  
* The 'user' part is specific to a particular configuration
    * please note: this part allows users to run their own code
* *GoThings* run in your Internet-of-Things, on the ARM achitecture boards such as the Raspberry Pi
* An alpha version of *GoThings* is now running in standard cloud virtual systems (It may be published during 2019)

<br />

* in [github](https://github.com/fpirri/gothings-install "github gothingscontrolmenu")  you find the **GoThingsControlMenu** to manage the lifecycle of your containers
* in [gothings-apps](https://github.com/fpirri/gothings-apps "github gothings-apps")  you find templates that can be customized for specific purposes
 
<br />  

<br />  
 
<br />  

----
  
----

PLEASE NOTE: this is WORK IN PROGRESS
===

<br />


  
Please be patient, I will do my best to include basic docs on github ASAP


- Status as October 3rd, 2019:

   - basic tests on Raspberry P1-B+ & PI Zero W passed
   - docker images available on dockerhub
      - go to https://hub.docker.com/ and search 'gothings'

   - building documentation on the dedicated 'bla bla site' (available ASAP)


----
<br />

------------------------------


#### GoThings is a Docker Distributed Things Operating System (DDT-OS) running on a number of networked things.

#### GoThings uses nodejs, vuejs and python-flask technologies.

#### GoThings networking is based on http protocol and exploits many of the nginx+lua+redis capabilities


------------------------------

<br/>

## Pre-installation steps


- Choose your raspbian image.

   - Unfortunately, docker runs only on a few of the available armv6l raspbian images
   - After many tries I choosed the following release:
   
        https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-11-15/2018-11-13-raspbian-stretch-lite.zip
 
 
   - You have to burn your sd-card and abilitate ssh.
    
   - Please follow the official instructions or google 'headless raspberry setup' and choose one of the many tutorials.    
      - I followed https://styxit.com/2017/03/14/headless-raspberry-setup.html

    

- Connect via ssh from a PC terminal on the same LAN
   - in terminal you can write:
   
        ssh pi@raspberrypi
        
      normally it automatically find the new board on LAN
      
   -  If that don't function please try googling 'find your raspberry IP address'  and connect via ssh from terminal:
        
          ssh pi@<your IP address>
          
          
- It is **VERY IMPORTANT** that you change your password to a very strong one ...

    -   **<-- PLEASE FOLLOW** this advice !!!


**You should now have a raspberry PI, reachable via ssh, which can run the GoThings system**
    
<br />

-------------------------------

<br />

# GoThings installation

<br />

#### 1- Connection
Connect to your board via ssh, commands below should be gived in the home directory /home/pi

#### 2- Download the 'zero' script
Exec the command:

      wget -O /home/pi/0 https://raw.githubusercontent.com/fpirri/gothings-install/master/0

The 0 (number zero) is the primary bootstrap script.
     
 To give yourself a minimum of security you should verify the integrity of the files you download from internet.  
To this end you have to calculate the checksum of the downloaded 0 file:  

       md5sum /home/pi/0  <-- you thype this
       54c6223a01420b9028720e9d5789adf3 /home/pi/0  <-- you see the locally calculated checksum

You should compare it with the file on github repository.
Content of github 0.md5 file is similar to:  
    
        54c6223a01420b9028720e9d5789adf3  /home/pi/0
        ---
        To evaluate the checksum above you may use the following command:
        md5sum /home/pi/0
        ---
        0  version 0.0.3
        ---
  
  
#### 3- Verify the 'zero' script
You should verify equality of the locally calculated checksum with that reported on the github repository

NOTE :  
  There are means of verification other than md5 checksum.
  Here MD5 is choosed because it is already available in the raspbian OS.  
 Security will be eventually improved later on

#### 4- exec the 0 script
Exec the command:

        . 0             <-- the command is:  'dot' 'space' 'number 0'

please note: this immediately executes the script locally, without the need to mark it as executable

#### 5- Install actions

 Follow the procedure suggested by the 0 script, one action at a time.  
**It is advisable to exec the first action only once.**  
You may execute the following sections multiple times, althought it should not be necessary.  
Last but one action dowload the  [g menu](https://github.com/fpirri/gothings-install "GoThingsControlMenu for things management") from github. It also allow you to exec the menu by typing './g' in the /home/pi/ directory.   
Anyway, Control Menu is not executed by this action, you should first verify its checksum after the download.  
Then, you may execute it by typeing ./g at the console.  


#### 6- Execution times
The execution time for each action is influenced by the raspberry board model and by the speed of your internet connection.  
Times below are for a raspberry P1B+ directly connected via LAN to a fast ADSL provider.  
Very similar times are obtained for the Raspberry PI zeroW board.

     A.1 First boot          :  4 m, including reboot;  
     A.2 Install utilities   : 7 m;  
     A.3 Setup user data     : less than 1 m;  
     A.4 Docker & docker-compose installation
                     docker  : 12 min;  
            compose  via PIP : 1h 15m;  
     A.5 Demo example
         images download : 32 m;   (first time only)
             run example : 2 m.  
         Note: this action can be safely interrupted and re-executed   
----------------------

<br /><hr />

# Enjoy docker !
-----

