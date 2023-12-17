#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

echo -e "\e[1;37mEnter DNS IPs separated by ' ':\e[0m"
read -a DNS_IPS

echo -e "\e[1;37mEnter Your NameServers separated by ' ':\e[0m"
read -a NAME_SERVERS

echo -e "\e[1;37mEnter Target DNS IP:\e[0m"
read TARGET_ADDRESS

LOOP_DELAY=2
echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"

DIG_EXEC="DEFAULT"
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig
VER=0.3

case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! $(command -v ${_DIG}) ]; then
  printf "%b" "Dig command failed to run, please install dig(dnsutils) or check the DIG_EXEC & CUSTOM_DIG variable.\n" && exit 1
fi

# Main loop
while true; do
  clear

  # Results
  for DI in "${DNS_IPS[@]}"; do
    for NS in "${NAME_SERVERS[@]}"; do
      result=$(${_DIG} @${DI} ${NS} +short)
      if [ -z "$result" ]; then
        STATUS="\e[92mSuccess\e[0m"
      else
        STATUS="\e[91mError\e[0m"
      fi

      echo -e "Name Server: ${NS} Status: ${STATUS}"
      echo -e "DNS IP: ${DI}"
      echo ""
    done
  done

  # Check count and Loop Delay
  echo -e "Check count: ${count}"
  echo -e "Loop Delay: ${LOOP_DELAY} seconds"
  
  sleep $LOOP_DELAY
  ((count++))  # Increment the counter
done

exit 0
