#!/bin/sh

RED=$(xrdb -query | grep "*.nord11:" | cut -f 2)
GREEN=$(xrdb -query | grep "*.nord14:" | cut -f 2)

status() {
  MUTED=$(pacmd list-sources | awk '/\*/,EOF {print}' | awk '/muted/ {print $2; exit}')

  if [ "$MUTED" = "yes" ]; then
    DISPLAY=" MUTE"
    UNDERLINE=$RED

  else
    DISPLAY=" $(pacmd list-sources | grep "\* index:" -A 7 | grep volume | awk -F/ '{print $2}' | tr -d ' ')"
    UNDERLINE=$GREEN
  fi

  echo "%{+u}%{u$UNDERLINE} $DISPLAY %{u-}"
}

listen() {
  status

  LANG=EN
  pactl subscribe | while read -r event; do
    if echo "$event" | grep -q "source" || echo "$event" | grep -q "server"; then
      status
    fi
  done
}

toggle() {
  MUTED=$(pacmd list-sources | awk '/\*/,EOF {print}' | awk '/muted/ {print $2; exit}')
  # DEFAULT_SOURCE=$(pacmd list-sources | awk '/\*/,EOF {print $3; exit}')
  DEFAULT_SOURCE=$(pacmd list-sources | awk '/\*/,EOF {print}' | awk '/index/ {print $3; exit}')

  if [ "$MUTED" = "yes" ]; then
    pacmd set-source-mute "$DEFAULT_SOURCE" 0
  else
    pacmd set-source-mute "$DEFAULT_SOURCE" 1
  fi
}

increase() {
  DEFAULT_SOURCE=$(pacmd list-sources | awk '/\*/,EOF {print $3; exit}')
  pacmd set-source-volume "$DEFAULT_SOURCE" +5%
}

decrease() {
  DEFAULT_SOURCE=$(pacmd list-sources | awk '/\*/,EOF {print $3; exit}')
  pacmd set-source-volume "$DEFAULT_SOURCE" -5%
}

case "$1" in
--toggle)
  toggle
  ;;
--increase)
  increase
  ;;
--decrease)
  decrease
  ;;
*)
  listen
  ;;
esac
