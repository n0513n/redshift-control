#!/usr/bin/env bash
#
# Simple bash script to interact with redshift
# And adjust screen colors and brightness.
#
# Usage:
#   redshift-control MAIN [--nocolor]
#
# Main arguments:
#   start      set automatic settings
#   pause      interrupt or activate redshift
#   stop       reset brightness and colors
#   up         brighten monitor screens
#   down       dim monitor screens
#   force      instant night colors

# Brightness (10 equals to 100%)
BRIGHTNESS='10'

# Temperature (6500 day - 4500 night)
DAYTEMP='6500'

# Force temperature value (optional)
FORCETEMP='3600'

# Cache file
CONF="/home/$USER/.cache/redshift_control"

# Main argument to execute
ARG="$(echo "$1" | sed s:-::g)"

# Optional; sets brightness without touching colors
[[ "$@" =~ '--nocolor' ]] &&
NOCOLOR=true || NOCOLOR=false

# Check running processes
RUNNING="$(ps aux | grep -w redshift | grep -v redshift-control | wc -l)"
[ "$RUNNING" -gt "1" ] && RUNNING=true || RUNNING=false

function help {
    head -n 15 "$0" | tail -n 10 | sed 's/# //;s/#//'; }

function brightness_up {
    b="$BRIGHTNESS"
    # Read brightness value from cache
    [ -f "$CONF" ] && b="$(cat $CONF)"
    # Set min/max brightness value
    [ "$b" -ge "10" ] && b='10'
    [ "$b" -le "1" ] && b='1'
    # Level brightness up and save to cache
    b=$(( $b + 1 )); echo "$b" > "$CONF"
    # Check value and convert to input format
    [ "$b" -gt "9" ] && b="1.0" || b="0.${b:0:1}"
    # Execute redshift and adjust brightness
    [ "$NOCOLOR" = "true" ] &&
    redshift -b $b -o -O $DAYTEMP -P ||
    redshift -b $b -o -P; }

function brightness_down {
    b="$BRIGHTNESS"
    # Read brightness value from cache
    [ -f "$CONF" ] && b="$(cat $CONF)"
    # Set min/max brightness value
    [ "$b" -ge "10" ] && b='10'
    [ "$b" -le "1" ] && b='1'
    # Level brightness up and save to cache
    b=$(( $b - 1 )); echo "$b" > "$CONF"
    # Check value and convert to input format
    [ "$b" -gt "9" ] && b="1.0" || b="0.${b:0:1}"
    # Execute redshift and adjust brightness
    [ "$NOCOLOR" = "true" ] &&
    redshift -b $b -o -O $DAYTEMP -P
    redshift -b $b -o -P; }

function redshift_start {
    echo 10 > "$CONF"
    redshift  &
    disown; }

function redshift_force {
    b="$BRIGHTNESS"
    # Read brightness value from cache
    [ -f "$CONF" ] && b="$(cat $CONF)"
    # Set min/max brightness value
    [ "$b" -ge "10" ] && b='10'
    [ "$b" -le "1" ] && b='1'
    # Check value and convert to input format
    [ "$b" -gt "9" ] && b="1.0" || b="0.${b:0:1}"
    # Execute redshift and adjust color & brightness
    redshift -b $b -o -O $FORCETEMP -P; }

function redshift_pause {
    pkill -USR1 '^redshift$'; }

function redshift_reset {
    redshift -o -x -P
    echo 10 > "$CONF"; }

# Execute

case "$ARG" in

    start)
        [[ $RUNNING = false ]] &&
        redshift_start
        ;;

    force)
        redshift_force
        ;;

    pause)
        [[ $RUNNING = false ]] &&
        redshift_reset &&
        redshift_start ||
        redshift_pause
        ;;

    stop|reset)
        redshift_reset
        ;;

    up|brightnessup)
        brightness_up
        ;;

    down|brightnessdown)
        brightness_down
        ;;

    help|*) # Default
        help
        ;;

esac # Finishes
