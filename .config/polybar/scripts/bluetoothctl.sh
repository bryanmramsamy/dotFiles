#!/bin/sh

# Colors
RED=$(xrdb -query | grep "*.nord11:" | cut -f 2)
BLUE=$(xrdb -query | grep "*.nord10:" | cut -f 2)
GREEN=$(xrdb -query | grep "*.nord14:" | cut -f 2)
WHITE=$(xrdb -query | grep "*.nord4:" | cut -f 2)
BLACK=$(xrdb -query | grep "*.nord0:" | cut -f 2)

ICON="󰂱"

bluetooth_print() {
  # Check if the Bluetooth service is running
  if ! systemctl is-active --quiet bluetooth.service; then
    printf "%%{B%s}%%{F%s} 󰂲 Service Down %%{F-}%%{B-}\n" "$RED" "$BLACK"
    return
  fi

  # Check if Bluetooth controller is available
  if bluetoothctl show 2>/dev/null | grep -q "No default controller available"; then
    printf "%%{F%s} 󰂲 No Controller %%{F-}\n" "$RED"
    return
  fi

  # Check if Bluetooth is powered on
  if bluetoothctl show | grep -q "Powered: yes"; then
    devices_paired=$(bluetoothctl devices Paired | grep Device | cut -d ' ' -f 2)
    counter=0

    for device in $devices_paired; do
      if bluetoothctl info "$device" | grep -q "Connected: yes"; then
        device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)

        if [ $counter -gt 0 ]; then
          printf "%%{F%s}%%{+u}%%{u%s} | %s %%{u-}%%{F-}" "$BLUE" "$BLUE" "$device_alias"
        else
          printf "%%{F%s}%%{+u}%%{u%s} %s %s %%{u-}%%{F-}" "$BLUE" "$BLUE" "$ICON" "$device_alias"
        fi

        counter=$((counter + 1))
      fi
    done

    # If no devices are connected, print Available
    if [ $counter -eq 0 ]; then
      printf "%%{F%s}%%{+u}%%{u%s} 󰂯 %%{u-}%%{F-}" "$WHITE" "$GREEN"
    fi
  else
    printf "%%{F%s}%%{+u}%%{u%s} 󰂲 %%{u-}%%{F-}\n" "$WHITE" "$RED"
  fi
}

bluetooth_toggle() {
  if bluetoothctl show | grep -q "Powered: no"; then
    bluetoothctl power on >/dev/null 2>&1
    sleep 1

    bluetoothctl devices Paired | grep Device | cut -d ' ' -f 2 | while read -r device; do
      bluetoothctl connect "$device" >/dev/null 2>&1
    done
  else
    bluetoothctl devices Paired | grep Device | cut -d ' ' -f 2 | while read -r device; do
      bluetoothctl disconnect "$device" >/dev/null 2>&1
    done
    bluetoothctl power off >/dev/null 2>&1
  fi
}

case "$1" in
--toggle)
  bluetooth_toggle
  ;;
*)
  bluetooth_print
  ;;
esac
