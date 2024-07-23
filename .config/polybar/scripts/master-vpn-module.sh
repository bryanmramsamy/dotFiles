#!/bin/bash
# NordVPN status module for Polybar

# Status
STATUS=`nordvpn status | grep "Status" | cut -d " " -f 4`
CITY=`nordvpn status | grep "City" | cut -d " " -f 2`
SERVER=`nordvpn status | grep "Current server" | cut -d " " -f 3 | cut -d "." -f 1`

# Colors
RED=`xrdb -query | grep "*light_red:"| cut -f 2`
YELLOW=`xrdb -query | grep "*light_yellow:"| cut -f 2`
BLUE=`xrdb -query | grep "*light_blue:"| cut -f 2`
WHITE=`xrdb -query | grep "*light_white:"| cut -f 2`
MAGENTA=`xrdb -query | grep "*dark_magenta:"| cut -f 2`

BLACK="#000000"
FOREGROUND=${BLACK}


if [[ $STATUS == Connected ]]; then
    DISPLAY=${SERVER^^}:${CITY}
    FOREGROUND=${WHITE}
    BACKGROUND=${BLUE}

elif [[ $STATUS == Connecting ]]; then
    FOREGROUND=${BLACK}
    DISPLAY='Connecting'
    BACKGROUND=${YELLOW}

else
    OPENVPN_CONNECTION=$(pgrep -a openvpn$ | head -n 1 | awk -F'/' '{print $NF}' | cut -d '.' -f 1)

    if [ -n "$OPENVPN_CONNECTION" ]; then
	
	if [[ $OPENVPN_CONNECTION == breast-international-group ]]; then
            DISPLAY="OVPN:Breast International Group"
            FOREGROUND=${WHITE}
	    BACKGROUND="#D3348B"

	elif [[ $OPENVPN_CONNECTION == 'Bryan Amoobi VPN' ]]; then
            DISPLAY="OVPN:amoobi"
            FOREGROUND=${WHITE}
	    BACKGROUND="#A62C36"

	else
            DISPLAY='Disconnected'
            BACKGROUND=${RED}
	fi

    else
        DISPLAY='Disconnected'
        BACKGROUND=${RED}
    fi
fi

echo "%{B$BACKGROUND}%{F$FOREGROUND}  $DISPLAY "
exit 0;
