#!/bin/bash

init(){

	gpio -g mode $pin pwm

	case "$1" in
	  on)
	    _on
	  ;;
	  off)
			_off
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
	gpio -g pwm $pin $dim
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

pin=$1
dim=$3
init $2

rm -f "$lockfile"
trap - INT TERM EXIT