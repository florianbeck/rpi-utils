#!/bin/bash
_iface=wlan0 #interface

enableAdHocNetwork(){
	if ! [[ $(pgrep -f wifi_ipcheck.sh) = "" ]]; then
		sudo pkill -f wifi_ipcheck.sh
	fi
	if ! [[ $(ifconfig | grep $_iface) = "" ]]; then
		ifdown $_iface
		sleep 1
	fi
	ifup $_iface=adhoc
	echo "wifi - ad-hoc mode enabled"
	echo "created network $(iwconfig $_iface | grep "ESSID:" | awk -F'[: ]+' '{print $5}'), ip $(ifconfig wlan0 | grep "inet " | awk -F'[: ]+' '{print $4}')"
	sudo $(dirname $0)/wifi_led.sh heartbeat &
}

enableDefaultNetwork(){
	if ! [[ $(pgrep -f wifi_ipcheck.sh) = "" ]]; then
		sudo pkill -f wifi_ipcheck.sh
	fi
	if ! [[ $(ifconfig | grep $_iface) = "" ]]; then
		ifdown $_iface
		sleep 1
	fi
	ifup $_iface=default
	echo "wifi - default mode enabled"
	sudo $(dirname $0)/wifi_led.sh blink &
	i=1
	while [ $i -le 15 ]
	do
	  if [[ $(ifconfig wlan0 | grep "inet " | awk -F'[: ]+' '{print $4}') = "" ]]; then
	  	sleep 1
	  else 
	  	break
	  fi
	  let i=$i+1
	done
	sudo $(dirname $0)/wifi_ipcheck.sh > /dev/null 2>&1 &
	echo "connected to $(iwconfig $_iface | grep "ESSID:" | awk -F'[: ]+' '{print $5}'), ip $(ifconfig wlan0 | grep "inet " | awk -F'[: ]+' '{print $4}')"
}

init(){
	case "$1" in
	  default)
	    enableDefaultNetwork
	  ;;
	 
	  adhoc)
	    enableAdHocNetwork
	  ;;

	  toggle)
			if [[ $(ifconfig | grep $_iface) = "" ]]; then
				enableDefaultNetwork
			else
				_mode=$(iwconfig $_iface | grep "Mode:" | awk -F'[: ]+' '{print $3}')

				if [ $_mode = "Ad-Hoc" ]; then
					enableDefaultNetwork
				else
					enableAdHocNetwork
				fi
			fi
		;;
	esac
}


# locking file and init
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

lockfile=$(dirname $0)/wifi_toggle.lock

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; then
  trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT

  init $1

  rm -f "$lockfile"
  trap - INT TERM EXIT
else
  if ps -p $(cat $lockfile) > /dev/null ; then
      echo "Script already running with pid $(cat $lockfile)" 
  else
      echo "Fixing orphaned lockfile: pid $(cat $lockfile) owning $lockfile does not exist"
      rm -f "$lockfile"
      ScriptLoc=$(readlink -f "$0")
      exec "$ScriptLoc"
  fi
fi