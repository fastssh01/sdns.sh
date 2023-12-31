#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

# Function definitions
parallel_dns_queries() {
  # Your parallel DNS queries logic here
  echo "Executing parallel DNS queries for $1"
}

perform_dns_query() {
  # Your DNS query logic here
  echo "Performing DNS query for $1, $2, $3"
}

# Manually set configuration options
read -p "Enable parallel queries? (y/n): " ENABLE_PARALLEL_CHOICE
read -p "Enable caching? (y/n): " ENABLE_CACHING_CHOICE

case "${ENABLE_PARALLEL_CHOICE}" in
  [Yy]*)
    ENABLE_PARALLEL=true
    ;;
  *)
    ENABLE_PARALLEL=false
    ;;
esac

case "${ENABLE_CACHING_CHOICE}" in
  [Yy]*)
    ENABLE_CACHING=true
    ;;
  *)
    ENABLE_CACHING=false
    ;;
esac

echo -e "\e[1;37mEnter DNS IPs separated by ' ':\e[0m"
read -a DNS_IPS

echo -e "\e[1;37mEnter Your NameServers separated by ' ':\e[0m"
read -a NAME_SERVERS

echo -e "\e[1;37mEnter Target DNS IP:\e[0m"
read TARGET_ADDRESS

LOOP_DELAY=5
echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"

DIG_EXEC="DEFAULT"
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig
VER=0.3

# User prompt for DNS lookup tool choice
echo -e "\e[1;37mChoose DNS lookup tool:\e[0m"
echo -e "\e[1;37m1. Default (dig)\e[0m"
echo -e "\e[1;37m2. host\e[0m"
echo -e "\e[1;37m3. nslookup\e[0m"

read -p "Enter your choice (1-3): " DNS_TOOL_CHOICE

case "${DNS_TOOL_CHOICE}" in
  1)
    _DIG="$(command -v dig)"
    ;;
  2)
    _DIG="$(command -v host)"
    ;;
  3)
    _DIG="$(command -v nslookup)"
    ;;
  *)
    echo "Invalid choice. Using default (dig)."
    _DIG="$(command -v dig)"
    ;;
esac

if [ ! $(command -v ${_DIG}) ]; then
  printf "%b" "DNS lookup tool not found. Please install the required tool or check your choice.\n" && exit 1
fi

# ...


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

  # Output of parallel DNS queries
  local parallel_output=""
  if [ "$ENABLE_PARALLEL" = true ]; then
    parallel_output=$(parallel_dns_queries "$TARGET_ADDRESS")
  fi

  # Output of caching
  local caching_output=""
  if [ "$ENABLE_CACHING" = true ]; then
    caching_output=$(perform_dns_query "target" "di" "ns")
  fi

  # Ping target address
  ping_result=$(ping -c 1 ${TARGET_ADDRESS} | grep "1 packets transmitted")
  if [ -n "$ping_result" ]; then
    ping_time=$(ping -c 1 ${TARGET_ADDRESS} | awk -F'/' 'END {printf "%.0f", $5}') # Round off without decimal points
    if (( ping_time <= 500 )); then # Changed the condition
      PING_STATUS="${reset_color}Ping Time:${reset_color} \e[92m${ping_time} ms\e[0m" # Green color for ping time below or equal to 500ms
    else
      PING_STATUS="${reset_color}Ping Time:${reset_color} \e[91m${ping_time} ms\e[0m" # Red color for ping time greater than 500ms
    fi
  else
    PING_STATUS="${fail_color}Ping Failed${reset_color}"
  fi

  # Manual control for parallel DNS queries
  if [ "$ENABLE_PARALLEL" = true ]; then
    echo -e "${border_color}│${padding}Parallel DNS Queries: ${parallel_output}${padding}${reset_color}"
  fi

  # Manual control for caching
  if [ "$ENABLE_CACHING" = true ]; then
    echo -e "${border_color}│${padding}Caching Result: ${caching_output}${padding}${reset_color}"
  fi

  if [ -z "$result" ]; then
    STATUS="${success_color}Success${reset_color}"
  else
    STATUS="${fail_color}Failed${reset_color}"
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
  echo -e "${border_color}├──────────────────────────────────────────────┤${reset_color
