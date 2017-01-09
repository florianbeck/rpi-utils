#!/bin/bash
source $(dirname $0)/../rpi-utils.conf

init(){
	while [ 1 ]; do
		if [[ $(ifconfig $WIFI_iface | grep "inet " | awk -F'[: ]+' '{print $4}') = "" ]]; then
			echo "noip"
			sudo $(dirname $0)/led.sh $WIFI_led_pin blink $WIFI_led_dim &
		else 
			echo "ip"
			sudo $(dirname $0)/led.sh $WIFI_led_pin on $WIFI_led_dim &
		fi
		sleep	5
	done
}

# locking file and init
filename=$(basename $0)
lockfile=$(dirname $0)/${filename%.*}.lock

if ! ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; then
  if ps -p $(cat $lockfile) > /dev/null ; then
  	kill -9 $(cat $lockfile)
  	rm -f "$lockfile"
  else 
  	pkill -f led.sh
  	rm -f "$lockfile"
  fi
  set -o noclobber; echo "$$" > "$lockfile"
fi
trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
#trap _term SIGTERM

init $1

rm -f "$lockfile"
trap - INT TERM EXIT