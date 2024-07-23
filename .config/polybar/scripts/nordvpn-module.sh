#!/bin/bash
# NordVPN status module for Polybar

# Status
LOGGED_IN=false

# Colors
RED=$(xrdb -query | grep "*.nord11:" | cut -f 2)
YELLOW=$(xrdb -query | grep "*.nord13:" | cut -f 2)
BLUE=$(xrdb -query | grep "*.nord10:" | cut -f 2)
WHITE=$(xrdb -query | grep "*.nord4:" | cut -f 2)
BLACK=$(xrdb -query | grep "*.nord0:" | cut -f 2)
LIGHT_BLACK=$(xrdb -query | grep "*.nord3:" | cut -f 2)

FOREGROUND=${WHITE}
BACKGROUND=${BLACK}
UNDERLINE=${BACKGROUND}

login_check() {
    if nordvpn account >/dev/null 2>&1; then
        LOGGED_IN=true
    fi
}

get_status() {
    NORDVPN_STATUS=$(nordvpn status)
    STATUS=$(echo "$NORDVPN_STATUS" | grep "Status" | cut -d " " -f 2)
    SERVER=$(echo "$NORDVPN_STATUS" | grep "Hostname" | cut -d " " -f 2)
    IP=$(echo "$NORDVPN_STATUS" | grep "IP" | cut -d " " -f 2)
}

main() {
    login_check

    if [[ $LOGGED_IN == true ]]; then
        get_status

        if [[ $STATUS == Connected ]]; then
            DISPLAY="${SERVER}  ${IP}"
            UNDERLINE=${BLUE}
            # ACTION=`nordvpn d`

        elif [[ $STATUS == Connecting ]]; then
            DISPLAY='Connecting'
            UNDERLINE=${YELLOW}

        else
            DISPLAY='Disconnected'
            FOREGROUND=${RED}
            UNDERLINE=${RED}
            # ACTION=`nordvpn c Netherlands`
        fi

    else
        DISPLAY="Unlogged"
        UNDERLINE=${LIGHT_BLACK}
    fi

    echo "%{B$BACKGROUND}%{F$FOREGROUND}%{+u}%{u$UNDERLINE} 󰖂 $DISPLAY %{u-}%{F-}%{B-}"
    exit 0
}

main
