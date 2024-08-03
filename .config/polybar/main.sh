#!/bin/bash
# Simplified Polybar launch script

# List of bars to launch
BARS=(
  top-monitor1
  bottom-monitor1
  top-monitor2
  bottom-monitor2
  top-monitor3
  bottom-monitor3
  top-monitor4
  bottom-monitor4
  top-monitor5
  bottom-monitor5
)

# Kill all existing Polybar instances
pids=$(pgrep -x polybar)
if [ -n "$pids" ]; then
  kill -9 $pids
fi

# Launch Polybar on all configured monitors
echo "Launching Polybars" | tee -a /tmp/polybar.log
for bar in "${BARS[@]}"; do
  polybar "$bar" >>/tmp/polybar.log 2>&1 &
done
echo "Polybars launched"
