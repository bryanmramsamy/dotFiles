#!/bin/bash
# Polybar launch script

HOSTNAME="Cassiopeia-2022"

killall -q polybar

xrdb $HOME/.Xresources # TODO: Should not be here

case $HOSTNAME in
"Butterfly-2019")
  echo "Lauching polybars" | tee -a /tmp/polybar.log
  polybar top-monitor1 >>/tmp/polybar.log 2>&1 &
  polybar bottom-monitor1 >>/tmp/polybar.log 2>&1 &
  polybar top-monitor2 >>/tmp/polybar.log 2>&1 &
  polybar bottom-monitor2 >>/tmp/polybar.log 2>&1 &
  polybar top-monitor3 >>/tmp/polybar.log 2>&1 &
  polybar bottom-monitor3 >>/tmp/polybar.log 2>&1 &
  echo "Polybars launched"
  ;;
"Cassiopeia-2022")
  echo "Lauching polybars" | tee -a /tmp/polybar.log
  polybar top-monitor1 >>/tmp/polybar.log 2>&1 &
  polybar bottom-monitor1 >>/tmp/polybar.log 2>&1 &
  polybar top-monitor2 >>/tmp/polybar.log 2>&1 &
  polybar bottom-monitor2 >>/tmp/polybar.log 2>&1 &
  polybar top-monitor3 >>/tmp/polybar.log 2>&1 &
  polybar bottom-monitor3 >>/tmp/polybar.log 2>&1 &
  polybar top-monitor4 >>/tmp/polybar.log 2>&1 &
  polybar bottom-monitor4 >>/tmp/polybar.log 2>&1 &
  polybar top-monitor5 >>/tmp/polybar.log 2>&1 &
  polybar bottom-monitor5 >>/tmp/polybar.log 2>&1 &
  echo "Polybars launched"
  ;;
esac
