#!/bin/bash

init(){

	pin=12
	high=5

	gpio -g mode $pin pwm

	case "$1" in
	  on)
	    gpio -g pwm $pin $high
	  ;;
	  off)
			gpio -g pwm $pin 0
		;;
		heartbeat)
			while [ 1 ]; do
				_heartbeat
			done
		;;
		blink)
			while [ 1 ]; do
				_blink	
			done		
		;;
	esac

}

_on(){
	gpio -g pwm $pin $high
}

_off(){
	gpio -g pwm $pin 0
}

_heartbeat(){
		_on
		sleep 0.2
		_off
		sleep 0.2			
		_on
		sleep 0.2
		_off
		sleep 1.4
}

_blink(){
	_on
	sleep 0.5
	_off
	sleep 0.5		
}

_term() { 
  gpio -g pwm $pin 0
}

# locking file and init
lockfile=$(dirname $0)/wifi_led.lock

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