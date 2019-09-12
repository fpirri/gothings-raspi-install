# GoThingsInstall

Script to install docker and running example on a Raspberry board  
<br />  

----
[What GoThingsInstall does]()
[What you get]()
[What you need]()
[GoThingsSystem short description]()
[Pre-installation steps]()
[GoThings installation]()

----

<br />

What GoThingsInstall does
----  

* ***GoThingsInstall*** offers you a simple menu of actions to install the ***GoThingsSystem***
* Lets you click/perform a sequence of actions to install docker on your raspberry pi board
* *GoThingsInstall* allows you to set locales, get some data from github and initialize the *GoThingsSystem*
* You can run a demo application
* You can also intall and execute the ***GoThingsControlMenu*** on the board  
  
   
 ***GoThingsSystem*** is briefly described below  
 
 ***GoThingsControlMenu*** is available on github at [GoThingsInstall](https://github.com/fpirri/gothingsinstall "GoThingsControlMenu") 

<br />  

What you get  
----  

   - docker installed in your raspberry pi (P1 & Pi Zero)
   - nginx running in your board as an HTTPS gateway to the external world
   - a basic HTTP service on-board
   - a NODE JS demo application you can modify
   - the ***GoThingsControlMenu*** to manage your GoThingsSystem

Through **GoThingsControlMenu** you manage the lifecycle of all containers and user data in the *GoThingsSystem*

Please note the docker installation is a standard one. The *GoThingsSystem* configuration data is made up from a few files and you may delete them and use docker for any other purpose.

After that you may write your programs using javascript, python or PHP languages. They will each run in its own container.  
  
<br />  

What you need
----  
  
* a raspberry P1-B+ or PI Zero W board
* an sd-card with raspbian-stretch-lite.zip  
     please note you need the 2018-11-13 raspbian version image, available at:

          https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-11-15/2018-11-13-raspbian-stretch-lite.zip
          
* an internet connection (you will download several big files)
* you may have to follow the **PRE-INSTALLATION** procedure documented below to run the raspbian system on your raspberry board
 
 Finally, please follow the instructions in the **INSTALLATION **section below
 
<br />  

GoThingsSystem short description  
----  

* The *GoThingsSystem* is made up from a number of co-operating docker containers
* each container does a specific function but all the ensemble is seen from the network as a single entity
    * each container may use a different language, i.e. javascript, python, PHP, ...
* The *GoThingsSystem* is made up from two parts: 'base' & 'user'
* The 'base' part gives to the GoThings system the capabilities common to most applications, such as network access and security  
* The 'user' part is specific to a particular configuration
    * please note: this part allows users to run their own code
* *GoThings* run in your Internet-of-Things, on the ARM achitecture boards such as the Raspberry Pi
* An alpha version of *GoThings* is now running in standard cloud virtual systems (It may be published during 2019)

<br />

* in [hlite-control](https://github.com/fpirri/hlite-control "github hlite-control")  you find the **GoThingsControlMenu** to manage the lifecycle of your containers
* in [hlite-apps](https://github.com/fpirri/hlite-apps "github hlite-apps")  you find templates that can be customized for specific purposes
 
<br />  

<br />  
 
<br />  

----
  
----

PLEASE NOTE: this is WORK IN PROGRESS
===

<br />


  
Please be patient, I will do my best to include basic docs on github ASAP


- Status as August 12th, 2019:

   - new tests on Raspberry P1-B+ & PI Zero W passed
   - docker images available on dockerhub
      - go to https://hub.docker.com/ and search 'hlite/nginx'


   - building documentation on the dedicated 'bla bla site' (available ASAP)


----
<br />

------------------------------


#### GoThings is a Docker Distributed Things Operating System (DDT-OS) running on a number of networked things.

#### Hlite things will use nodejs, vuejs and python-flask technologies.

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
      
   -  If that don't function please try googling 'find your raspberry IP address'
      
        and connect via ssh from terminal:
        
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

#### 2- Download boot.sh
Exec the command:

      wget -O ~/boot.sh https://raw.githubusercontent.com/fpirri/hlite-install/master/boot.sh

The boot.sh file is the primary bootstrap script.
     
3-   To give yourself a minimum of security you should verify the integrity of the files you download from internet.  
To this end you have to calculate the checksum of the downloaded boot.sh file:  

       md5sum /home/pi/boot.sh  <-- you thype this
       54c6223a01420b9028720e9d5789adf3 /home/pi/boot.sh  <-- you see the locally calculated checksum

You should compare it with the file on github repository.
Content of github boot.sh.md5 file is similar to:  
    
        54c6223a01420b9028720e9d5789adf3  /home/pi/boot.sh
        ---
        To evaluate the checksum above you may use the following command:
        md5sum /home/pi/boot.sh
        ---
        boot.sh  version 0.0.3
        ---

You should verify equality of the locally calculated checksum with that reported on the github repository

NOTE :  
  There are means of verification other than md5 checksum.
  Here MD5 is choosed because it is already available in the raspbian OS
 Security will be eventually improved in a following version of fastinstall

#### 4- download fastinstall
Exec the command:

        . boot.sh

please note: the command is a dot followed by a space, then the name of the script (boot.sh)  
The script will be immediately executed

#### 5- Fastinstal
Now you have a link to the fastinstall.sh script in your root dir

     - you can execute fastinstall by typing: './fastinstall'

 Follow the procedure suggested by the fastinstall script, one section at a time.  
It is advisable to exec the first step only once, it will take a few minutes.  
You may execute the following sections multiple times, althought it should not be necessary.  
Last section dowload the  [GoThingsControlMenu](https://github.com/fpirri/hlite-control "GoThingsSystem management menu") from github. It also allow you to exec the menu by typing './controlmenu' in the /home/pi/ directory.   
Anyway, Control Menu is not executed by this action, you should verify it before execution.  

#### 7- Execution time
The execution time for each section is influenced by the raspberry board and by the speed of your internet connection.  
Time below are for a raspberry P1B+ directly connected via LAN to a fast ADSL provider.  

     A.1  First boot : 4 m, including reboot;  
     A.2 Install utilities : 7 m;  
     A.3 Setup user data : less than 1 m;  
     A.4 Docker installation : 12 min;  
     A.4 bis - Docker-conmpose installation via python PIP : 1h 15m;  
     A.5 Demo example - docker images download : 32 m;  
       --> note: images download is only executed first time;  
       --> this action can be interrupted and re-executed  
     A.5 bis - Run example : 2 m.  
 
----------------------

<br /><hr />

# Enjoy docker !
-----

<br />

---
### History

2019-09-10
   - documentation update

2019-08-12
   - docker version 8.06.1~ce~3-0~raspbian  now ok
       - exact cause of misconfiguration was not found
       - adjusting fastinstall.sh and a fresh restart from a clean raspbian corrected the problem

2019-08-09
   - docker version 8.06.1~ce~3-0~raspbian  no more starts
       - it used to run fine for a few weeks
       - probably, an 'sudo apt upgrade' misconfigured something
       - start searching for the cause of error

2019-07-18
   - hlite-install version 0.1 runs !
      - raspbian version:  2018-11-13-raspbian-stretch-lite
      - docker-ce version: 8.06.1~ce~3-0~raspbian

