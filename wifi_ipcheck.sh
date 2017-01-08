#!/bin/bash

init(){
	while [ 1 ]; do
		if [[ $(ifconfig wlan0 | grep "inet " | awk -F'[: ]+' '{print $4}') = "" ]]; then
			echo "noip"
			sudo $(dirname $0)/wifi_led.sh blink &
		else 
			echo "ip"
			sudo $(dirname $0)/wifi_led.sh on &
		fi
		sleep	5
	done
}

# locking file and init
lockfile=$(dirname $0)/wifi_ipcheck.lock

if ! ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; then
  if ps -p $(cat $lockfile) > /dev/null ; then
  	kill -9 $(cat $lockfile)
  	rm -f "$lockfile"
  else 
  	pkill -f wifi_led.sh
  	rm -f "$lockfile"
  fi
  set -o noclobber; echo "$$" > "$lockfile"
fi
trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
#trap _term SIGTERM

init $1

rm -f "$lockfile"
trap - INT TERM EXIT