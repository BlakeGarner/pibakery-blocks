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

# Sanitize Input
re="^[0-9]+$"
if ! [[ $1 =~ $re ]]; then
        echo "Pin not an integer."
        exit 1
fi

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

A=("none" "kbd-scrolllock" "kbd-numlock" "kbd-capslock" "kbd-kanalock" \
        "kbd-shiftlock" "kbd-altgrlock" "kbd-ctrllock" "kbd-altlock" \
        "kbd-shiftllock" "kbd-shiftrlock" "kbd-ctrlllock" "kbd-ctrlrlock" \
        "timer" "oneshot" "heartbeat" "backlight" "gpio" "cpu0" "cpu1" "cpu2" \
        "cpu3" "default-on" "[input]" "panic" "mmc0" "mmc1" "rfkill0" "rfkill1")
if [ -z "$2" ]; then
        echo "Activity function not defined"
        exit 1
fi

if [ $(contains "${A[@]}" "$2") == "n" ]; then
        echo "Activity function not recognised"
        exit 1
fi


ACT_PIN=$1
ACT_FUNCTION=$2
CONFIG_FILE="/boot/config.txt"

replaceAppend $CONFIG_FILE "^dtparam=act_led_gpio=.*"    "dtparam=act_led_gpio=$1          # For Pi 0\/1\/1+\/2"
replaceAppend $CONFIG_FILE "^dtoverlay=pi3-act-led.*"    "dtoverlay=pi3-act-led,gpio=$1    # For Pi 3\/3+"
replaceAppend $CONFIG_FILE "^dtparam=act_led_trigger=.*" "dtparam=act_led_trigger=$2\n"

