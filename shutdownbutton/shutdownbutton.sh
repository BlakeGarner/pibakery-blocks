#!/bin/bash

# Helper Functions
replaceAppend() {
        grep $2 $1 >/dev/null
        if [ $? -eq 0 ]; then
                # Pattern found; append on new line (silently)
                sed -i "s/$2/$3/g" $1 >/dev/null
        else
                # Not found; append on new line (silently)
#               echo $3 | sudo tee -a $1 >/dev/null
                sed "$ a $3" -i $1
        fi
}

function contains() {
        local n=$#
        local value=${!n}
        for ((i==1;i < $#;i++)) {
                if [ "${!i}" == "${value}" ]; then
                        echo "y"
                        return 0
                fi
        }
        echo "n"
        return 1
}

# Sanitize Input
re="^[0-9]+$"
if ! [[ $1 =~ $re ]]; then
        echo "Pin not an integer."
        exit 1
fi

A=("off" "down" "up")
if [ -z "$2" ]; then
        echo "Pull-up/down state not defined."
        exit 1
fi

if [ $(contains "${A[@]}" "$2") == "n" ]; then
        echo "Pull-up/down state not recognised. Must be one of: off, down, up"
        exit 1
fi

A=("falling" "rising")
if [ -z "$3" ]; then
        echo "Active-low not defined."
        exit 1
fi

if [ $(contains "${A[@]}" "$3") == "n" ]; then
        echo "Active low must be 1 (falling edge) or 0 (rising edge)"
        exit 1
fi


SHUTDOWN_PIN=$1
SHUTDOWN_PULLUP=$2
SHUTDOWN_EDGE=1

if [ "$3" == "rising" ]; then
	SHUTDOWN_EDGE=0
fi

CONFIG_FILE="/boot/config.txt"

# Configure boot/config.txt
replaceAppend $CONFIG_FILE "^dtoverlay=gpio-shutdown.*" "dtoverlay=gpio-shutdown,gpio_pin=$SHUTDOWN_PIN,active_low=$SHUTDOWN_EDGE,gpio_pull=$SHUTDOWN_PULLUP\n"
