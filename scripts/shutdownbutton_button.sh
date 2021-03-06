#!/bin/bash
source $(dirname $0)/../rpi-utils.conf

_term() { 
  echo "Caught SIGTERM signal!" 
  echo "$child"
  kill -9 "$child" 2>/dev/null
}

init(){

  if [[ $1 = "" ]]; then
    pin=$SHUTDOWN_btn_pin
  else 
    pin=$1
  fi

  echo "pin $pin"

  gpio -g mode $pin in
  gpio -g mode $pin up

  while [ 1 ] ; do
    echo "waiting"
    gpio -g wfi $pin falling &
    child=$!
    wait "$child"
    echo "button pressed, shutdown"
    sudo $(dirname $0)/led.sh $WIFI_led_pin off &
    sudo shutdown now
  done
}

# locking file and init
filename=$(basename $0)
lockfile=$(dirname $0)/${filename%.*}.lock

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null; then
  trap 'rm -f "$lockfile"; _term; exit $?' INT TERM EXIT

  init $1

  rm -f "$lockfile"
  trap _term INT TERM EXIT
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