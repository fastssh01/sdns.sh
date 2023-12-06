#!/bin/bash

## Copyright ©UDPTeam

## Discord: [URL]https://discord.gg/civ3[/URL]

## Script to keep-alive your DNSTT server domain record query from target resolver/local dns server

## Run this script excluded to your VPN tunnel (split VPN tunneling mode)

## run command: ./universe02.sh l

## Repeat dig cmd loop time (seconds) (positive integer only)
LOOP_DELAY=5

## Linux' dig command executable filepath

## Select value: "CUSTOM|C" or "DEFAULT|D"

DIG_EXEC="DEFAULT"

## if set to CUSTOM, enter your custom dig executable path here

CUSTOM_DIG="/data/data/com.termux/files/home/go/bin/fastdig"

######################################
######################################
######################################
######################################
######################################

VER=0.1

# 1. Input Collection
IFS=' ' read -ra HOSTS -p "Enter DNS IPs separated by ' ': "
IFS=' ' read -ra NS -p "Enter Your NameServers separated by ' ': "

# 4. Error Handling
case "${DIG_EXEC}" in
DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! "$_DIG" ]; then
    printf "Dig command failed to run, please install dig (dnsutils) or check DIG_EXEC & CUSTOM_DIG variables inside $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename "$0") file.\n"
    exit 1
fi

endscript() {
    unset NS HOSTS _DIG DIG_EXEC CUSTOM_DIG LOOP_DELAY
    exit 1
}

trap endscript 2 15

# 2. Main Loop (Infinite Loop)
while true; do
    # 3. Check Function
    for R in "${NS[@]}"; do
        for T in "${HOSTS[@]}"; do
            # Check if the DNS server is responsive on port 53
            if nc -z -w 2 "$T" 53; then
                M="32"
            else
                M="31"
            fi
            timeout -k 3 3 ${_DIG} @${T} ${R} &>/dev/null
            echo -e "\e[${M}m${R} D:${T}\e[0m"
        done
    done
    sleep "${LOOP_DELAY}"
done

exit 0
