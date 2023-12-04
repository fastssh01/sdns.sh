#!/bin/bash

clear

function endscript() {
  echo -e "\nScript terminated."
  exit 1
}

trap endscript 2 15

function display_header() {
  local header_text=$1
  local header_length=${#header_text}
  local border_color="\e[95m"  # Light magenta color
  local reset_color="\e[0m"    # Reset to default terminal color
  local padding="  "            # Padding for aesthetic

  # Header
  echo -e "${border_color}$(printf '=%.0s' $(seq 1 $((header_length + 6))))${reset_color}"
  echo -e "${border_color}â”‚${padding}${header_text}${padding}${reset_color}"
  echo -e "${border_color}$(printf '=%.0s' $(seq 1 $((header_length + 6))))${reset_color}"
}

echo -e "\e[1;37mEnter DNS IPs separated by ' ': \e[0m"
read -a DNS_IPS

echo -e "\e[1;37mEnter Your NameServers separated by ' ': \e[0m"
read -a NAME_SERVERS

LOOP_DELAY=5
echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"
read -p "Would you like to change the loop delay? [y/n]: " change_delay

if [[ "$change_delay" == "y" ]]; then
  read -p "Enter custom loop delay in seconds (5-15): " custom_delay
  if [[ "$custom_delay" =~ ^[5-9]$|^1[0-5]$ ]]; then
    LOOP_DELAY=$custom_delay
  else
    echo -e "\e[1;31mInvalid input. Using default loop delay of ${LOOP_DELAY} seconds.\e[0m"
  fi
fi

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

if ! command -v "${_DIG}" &> /dev/null; then
  echo -e "\e[1;31mDig command not found. Please install dig (dnsutils) or check DIG_EXEC & CUSTOM_DIG variables.\e[0m"
  endscript
fi

count=1

function check_dns_status() {
  local DNS_IP=$1
  local NAME_SERVER=$2
  local query_type="A"  # Adjust the query type based on your needs
  local result=$(${_DIG} "@${DNS_IP}" "${NAME_SERVER}" ${query_type} +short +timeout=5 +retry=3)

  if [ -z "$result" ]; then
    echo -e "DNS IP: ${DNS_IP}, NameServer: ${NAME_SERVER}, QueryType: ${query_type}, Status: \e[91mFailed\e[0m"
  else
    echo -e "DNS IP: ${DNS_IP}, NameServer: ${NAME_SERVER}, QueryType: ${query_type}, Status: \e[92mSuccess\e[0m, Result: ${result}"
  fi
}

function countdown() {
  for i in {5..1}; do
    echo -e "Checking will start in ${i} seconds..."
    sleep 1
  done
}

echo -e "\nBegin....\n"
countdown
clear

while true; do
  display_header "DNS Status Check Results"
  for DNS_IP in "${DNS_IPS[@]}"; do
    for NAME_SERVER in "${NAME_SERVERS[@]}"; do
      check_dns_status "${DNS_IP}" "${NAME_SERVER}"
    done
  done

  display_header "Check count: ${count}, Loop Delay: ${LOOP_DELAY} seconds"

  ((count++))
  sleep $LOOP_DELAY
  clear
done
