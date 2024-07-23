#!/usr/bin/env python3
# TODO: Improve script
import subprocess
import dbus
import signal
import time
from unicodedata import east_asian_width

# Config options

# (int) : Length of media info string. If length of string exceeds this value, the text will scroll. Default value is 20
message_display_len = 20

# (int) : Font index of polybar. this value should be 1 more than the font value specified in polybar config.
font_index = 1

# (float) : Update speed of the text in seconds.
update_delay = 0.5

# (list) : list of chars containing previous, play, pause, next glyphs for media controls in respective order
control_chars = ['', '', '', '']

# (dict) : dict of char icons to display as prefix.
# If player name is available as key, then use the corresponding icon,
# else default key value.
# example:
display_player_prefix = {
    "spotify":  '',
    "firefox":  '',
    "vlc": '󰕼',
    "default":  ''
}

no_player_text = "  No media playing"


# (list) : list of metadata fields based on mpris specification.
# For more details/ field names, refer [mpris sepecification](https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/)
metadata_fields = ["xesam:title", "xesam:artist"]

# (char) : separator for metadata fields
metadata_separator = "-"

# (bool) : Hide text when no player is available? True disables the output for no players.
hide_output = True


def get_xresources_color(name):
    try:
        output = subprocess.run(
            ['xrdb', '-query'], capture_output=True, text=True)
        for line in output.stdout.splitlines():
            if line.startswith(name + ":"):
                return line.split(":", 1)[1].strip()
    except Exception as e:
        print(f"Error fetching {name} from .Xresources: {e}")
    return None


# (str) : Color for underline when media is playing
playing_underline_color = get_xresources_color(
    "*.nord15") or "#00ff00"

# (str) : Color for underline when media is paused
paused_underline_color = get_xresources_color(
    "*.nord12") or "#FF0000"

playing_text_color = get_xresources_color(
    "*.nord15") or "#00ff00"

# (str) : Color for underline when media is paused
paused_text_color = get_xresources_color(
    "*.nord12") or "#FF0000"

# (str) : Color for underline when no player is active
no_player_underline_color = get_xresources_color(
    "*.nord11") or "#0000FF"

# (str) : Color for text when no player is active
no_player_text_color = get_xresources_color(
    "*.nord11") or "#FFFFFF"

disabled_color = get_xresources_color(
    "*.nord3") or "#FFFFFF"


# Defult initialization
current_player = None
display_text_color = ""
player_names = None
players = None
message = None
display_text = ""
display_prefix = " "
display_suffix = " "
last_player_name = None
underline_color = ""
status_paused = True

session_bus = dbus.SessionBus()

def get_name(player_name):
    if player_name not in player_names:
        return
    name = ".".join(player_name.split(".")[3:])
    return name

def get_name_by_index(index):
    if index >= len(player_names):
        return
    return get_name(player_names[index])

def get_status(player):
    status = ""
    try:
        status = player.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus',
                            dbus_interface='org.freedesktop.DBus.Properties')
    except Exception as e:
        pass
    return status

def get_metadata(player):
    metadata = {}
    try:
        metadata = player.Get('org.mpris.MediaPlayer2.Player', 'Metadata',
                              dbus_interface='org.freedesktop.DBus.Properties')
    except Exception as e:
        pass
    return metadata


def update_prefix_suffix(player_name="", status=""):
    global display_prefix, display_suffix, status_paused

    player_option = ""
    if player_name != "":
        player_option = "-p " + player_name

    prev_button = "%%{A:playerctl %s previous :}%c%%{A}" % (
        player_option, control_chars[0])
    play_button = "%%{A:playerctl %s play :}%c%%{A}" % (
        player_option, control_chars[1])
    pause_button = "%%{A:playerctl %s pause :}%c%%{A}" % (
        player_option, control_chars[2])
    next_button = "%%{A:playerctl %s next :}%c%%{A}" % (
        player_option, control_chars[3])

    suffix = " | " + prev_button
    if status == "Playing":
        suffix += " "+pause_button
        status_paused = False
    else:
        suffix += " "+play_button
        status_paused = True
    suffix += " "+next_button
    display_suffix = suffix

    for key in display_player_prefix.keys():
        if key in player_name:
            display_prefix = display_player_prefix[key] + " "
            break
    else:
        display_prefix = display_player_prefix["default"] + " "

def update_players():
    global player_names, players, session_bus, current_player, last_player_name
    player_names = [service for service in session_bus.list_names(
    ) if service.startswith('org.mpris.MediaPlayer2.')]
    players = [session_bus.get_object(
        service, '/org/mpris/MediaPlayer2') for service in player_names]
    if last_player_name != get_name(current_player):
        for index, player in enumerate(player_names):
            if get_name(player) == last_player_name:
                current_player = index

def handle_event(*args):
    global current_player, players, last_player_name
    update_players()
    if len(players) == 0:
        return
    current_player += 1
    current_player %= len(players)
    last_player_name = get_name_by_index(current_player)



def scroll():
    global display_text, message_display_len, status_paused
    if not status_paused:
        if visual_len(display_text) > message_display_len:
            display_text = display_text[1:] + display_text[0]
        elif visual_len(display_text) < message_display_len:
            display_text += " "*(message_display_len - len(display_text))

def visual_len(text):
    visual_length = 0
    for ch in text:
        width = east_asian_width(ch)
        if width == 'W' or width == 'F':
            visual_length += 2
        visual_length += 1
    return visual_length

def make_visual_len(text, visual_desired_length):
    visual_length = 0
    altered_text = ''
    for char in text:
        if visual_length < visual_desired_length:
            width = east_asian_width(char)
            if width == 'W' or width == 'F':
                visual_length += 2
            else:
                visual_length += 1
            altered_text += char
        else:
            break
    if visual_length == visual_desired_length + 1:
        altered_text = altered_text[:-1] + ' '
    elif visual_length < visual_desired_length:
        altered_text += ' ' * (visual_desired_length - visual_length)
    return altered_text


def update_message():
    global players, current_player, player_names, message, display_text, message_display_len, display_suffix, last_player_name, underline_color, display_text_color
    if len(players) == 0:
        tmp_message = no_player_text
        update_prefix_suffix()
        underline_color = no_player_underline_color
        display_text_color = no_player_text_color
    else:
        name = get_name_by_index(current_player)
        status = get_status(players[current_player])
        metadata_obj = get_metadata(players[current_player])
        metadata_string_list = []
        for field in metadata_fields:
            result = metadata_obj.get(field)
            if type(result) == dbus.Array:
                result = result[0]
            if not result:
                result = "No "+field.split(":")[1]
            metadata_string_list.append(str(result))
        metadata_string = (" "+metadata_separator +
                           " ").join(metadata_string_list)
        if visual_len(metadata_string) > message_display_len:
            metadata_string = " " + metadata_string + " |"
        update_prefix_suffix(name, status)
        tmp_message = metadata_string
        last_player_name = name
        underline_color = playing_underline_color if status == "Playing" else paused_underline_color
        display_text_color = playing_text_color if status == "Playing" else paused_text_color
    if message != tmp_message:
        message = tmp_message
        display_text = message


def print_text():
    global display_text, message_display_len, players, player_names, display_prefix, display_suffix, underline_color, display_text_color
    if hide_output and len(players) == 0:
        print("", flush=True)
        return
    scroll()
    if len(players) != 0:
        print("%%{u%s}%%{+u} %%{F%s}%s %s %s %%{F-}%%{u-}" % (
            underline_color, display_text_color, display_prefix.strip(),
            make_visual_len(
                display_text, message_display_len),
            display_suffix.strip()
        ), flush=True)
    else:
        print("%%{u%s}%%{+u} %%{F%s}%s %s%%{F-} %%{F%s}%s %%{F-}%%{u-}" % (
            underline_color, display_text_color, display_prefix.strip(),
            make_visual_len(
                display_text, message_display_len),
            disabled_color,
            display_suffix.strip()
        ), flush=True)



def main():
    global current_player, players
    update_players()
    current_player = 0
    while True:
        time.sleep(update_delay)
        update_players()
        update_message()
        print_text()

if __name__ == '__main__':
    signal.signal(signal.SIGUSR1, handle_event)
    main()
