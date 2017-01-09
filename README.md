#RaspberryPi Utilities

The RaspberryPi Utilities bring two functions to your RaspberryPi:  
**`$ wifi`** and **`$ shutdownbutton`**

With `$ wifi` you can toggle your wifi interface between acting as **client** (connect to existing wifi, get ip via dhcp) or **accesspoint** (create ad-hoc network).  
The status of the interface is indicated by an led and there is a button for quick toggle between the two modes.

`$ shutdownbutton` provides a secure way to shutdown your RaspberryPi.

##Installation

Install the RaspberryPi Utilities from shell prompt:

```sh
wget https://github.com/florianbeck/rpi-utils/archive/master.zip
unzip master.zip
./rpi-utils-master/install.sh
```

##Config
There are some configuration options – like button and led pins – available in the `rpi-utils.conf` file.

##Hardware
The RaspberryPi Utilities are designed to work with a little peace of hardware:  
– push button and status led for `$ wifi`  
– push button for `$shutdownbutton`  

The default pins used by the script can be edited in the `rpi-utils.conf` file.

The buttons should bring the pin to ground. The leds anode should be connected to the pin, the cathode to ground.

##Usage

### `$ wifi`

```
wifi - toggle between default and ad-hoc mode

usage: wifi set [default|adhoc]
       [default: wifi interface acts as client]
       [adhoc:   wifi interface acts as accesspoint]
usage: wifi toggle
       [toggle between default and adhoc]
usage: wifi config
       [edit wpa_supplicant.conf]
usage: wifi status
       [status info provided by ifconfig and iwconfig]
usage: wifi button [start|stop]
       [start/stop the button event listener]
```

### `$ shutdownbutton`

```
shutdownbutton - button to trigger shutdown command

usage: shutdownbutton [start|stop]
       [start/stop the button event listener]
```