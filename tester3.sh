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

DNS_IPS=("124.6.181.12" "124.6.181.4" "124.6.181.28" "112.198.115.60" "112.198.115.44" "112.198.115.36" "124.6.181.20")

NAME_SERVERS=("sg2ray-dns.mainssh.com" "mine-ns.min3sacrifice.com")

TARGET_ADDRESS="8.8.8.8"

LOOP_DELAY=5
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

# Initialize the counter
count=1

check(){
  local border_color="\e[95m"  # Light magenta color
  local success_color="\e[92m"  # Light green color
  local fail_color="\e[91m"    # Light red color
  local header_color="\e[96m"  # Light cyan color
  local reset_color="\e[0m"    # Reset to default terminal color
  local padding="  "            # Padding for aesthetic

# Ping target address
ping_result=$(ping -c 1 ${TARGET_ADDRESS} | grep "1 packets transmitted")
if [ -n "$ping_result" ]; then
ping_time=$(ping -c 1 ${TARGET_ADDRESS} | awk -F'/' 'END {printf "%.0f", $5}') # Round off without decimal points
if (( ping_time <= 500 )); then # Changed the condition
PING_STATUS="${reset_color}Ping Time:${reset_color} \e[92m${ping_time} ms\e[0m" # Green color for ping time below or equal to 5>
else
PING_STATUS="${reset_color}Ping Time:${reset_color} \e[91m${ping_time} ms\e[0m" # Red color for ping time greater than 500ms
fi
else
PING_STATUS="${fail_color}Ping Failed${reset_color}"
fi
  # Header
  echo -e "${border_color}┌──────────────────────────────────────────────┐${reset_color}"
  echo -e "${border_color}│${header_color}${padding}DNS Status Check Results${padding}${reset_color}"
  echo -e "${border_color}├──────────────────────────────────────────────┤${reset_color}"
  
  # Results
  for DI in "${DNS_IPS[@]}"; do
    for NS in "${NAME_SERVERS[@]}"; do
      result=$(${_DIG} @${DI} ${NS} +short)
      if [ -z "$result" ]; then
        STATUS="${success_color}Success${reset_color}"
      else
        STATUS="${fail_color}Failed${reset_color}"
      fi

      echo -e "${border_color}│${padding}${reset_color}DNS IP: ${DI}${padding}${reset_color}"

      echo -e "${border_color}│${padding}Status: ${STATUS}${padding}${reset_color}"
      echo -e "${border_color}│${padding}${PING_STATUS}${padding}${reset_color}"
      echo -e "${border_color}├──────────────────────────────────────────────┤${reset_color}"
    done
  done

  # Check count and Loop Delay
  echo -e "${border_color}├──────────────────────────────────────────────┤${reset_color}"
  echo -e "${border_color}│${padding}${header_color}Check count: ${count}${padding}${reset_color}"
  echo -e "${border_color}│${padding}Loop Delay: ${LOOP_DELAY} seconds${padding}${reset_color}"
 
  # Footer
  echo -e "${border_color}└──────────────────────────────────────────────┘${reset_color}"
}

countdown() {
    for i in 5 4 3 2 1 0; do
        echo "Checking started in $i seconds..."
        sleep 1
    done
}
echo""
echo""
echo "Begin...."
echo""
echo""
countdown
  clear

# Main loop
while true; do
  check
  ((count++))  # Increment the counter
  sleep $LOOP_DELAY
done

exit 0
