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

ENABLE_PARALLEL=false
ENABLE_CACHING=false

[[ "${ENABLE_PARALLEL_CHOICE}" =~ [Yy] ]] && ENABLE_PARALLEL=true
[[ "${ENABLE_CACHING_CHOICE}" =~ [Yy] ]] && ENABLE_CACHING=true

# User input for DNS IPs, NameServers, and Target DNS IP
echo -e "\e[1;37mEnter DNS IPs separated by ' ':\e[0m"
read -a DNS_IPS

echo -e "\e[1;37mEnter Your NameServers separated by ' ':\e[0m"
read -a NAME_SERVERS

echo -e "\e[1;37mEnter Target DNS IP:\e[0m"
read TARGET_ADDRESS

LOOP_DELAY=5
echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"

# User prompt for DNS lookup tool choice
echo -e "\e[1;37mChoose DNS lookup tool:\e[0m"
echo -e "\e[1;37m1. Default (dig)\e[0m"
echo -e "\e[1;37m2. host\e[0m"
echo -e "\e[1;37m3. nslookup\e[0m"

read -p "Enter your choice (1-3): " DNS_TOOL_CHOICE

case "${DNS_TOOL_CHOICE}" in
  1) _DIG="$(command -v dig)" ;;
  2) _DIG="$(command -v host)" ;;
  3) _DIG="$(command -v nslookup)" ;;
  *) echo "Invalid choice. Using default (dig)." ; _DIG="$(command -v dig)" ;;
esac

if [ ! "$(command -v "${_DIG}")" ]; then
  printf "%b" "DNS lookup tool not found. Please install the required tool or check your choice.\n" && exit 1
fi

# Initialize the counter
count=1

check() {
  local success_color="\e[92m"  # Light green color
  local fail_color="\e[91m"     # Light red color
  local box_color="\e[94m"      # Light blue color for box line
  local reset_color="\e[0m"      # Reset to default terminal color
  local padding="  "             # Padding for aesthetic

  # Initialize STATUS based on selected options
  STATUS=""
  [ "${ENABLE_PARALLEL}" = true ] && STATUS+="Parallel DNS "
  [ "${ENABLE_CACHING}" = true ] && STATUS+="Caching "

  # Ping target address
  ping_result=$(ping -c 1 "${TARGET_ADDRESS}" 2>&1 | grep "transmitted")
  if [ -n "${ping_result}" ]; then
    ping_time=$(ping -c 1 "${TARGET_ADDRESS}" | awk -F'/' 'END {printf "%.0f", $5}')
    if (( ping_time <= 500 )); then
      PING_STATUS="${reset_color}Ping Time:${reset_color} \e[92m${ping_time} ms\e[0m"
    else
      PING_STATUS="${reset_color}Ping Time:${reset_color} \e[91m${ping_time} ms\e[0m"
    fi
  else
    PING_STATUS="${fail_color}Ping Failed${reset_color}"
  fi

  # Manual control for parallel DNS queries
  if [ "${ENABLE_PARALLEL}" = true ]; then
    parallel_dns_queries "${TARGET_ADDRESS}" &>/dev/null
    PARALLEL_STATUS="${success_color}Success${reset_color}"
  else
    PARALLEL_STATUS="${fail_color}Failed${reset_color}"
  fi

  # Manual control for caching
  if [ "${ENABLE_CACHING}" = true ]; then
    perform_dns_query "${DNS_IPS[*]}" "${NAME_SERVERS[*]}" "${TARGET_ADDRESS}" &>/dev/null
    CACHING_STATUS="${success_color}Success${reset_color}"
  else
    CACHING_STATUS="${fail_color}Failed${reset_color}"
  fi

  # Display the results without extra output
  echo -e "${box_color}┌──────────────────────────────────────────────┐${reset_color}"
  echo -e "${box_color}│${padding}Status: ${STATUS}${padding}${reset_color}"
  echo -e "${box_color}│${padding}DNS IPs: ${DNS_IPS[*]}${padding}${reset_color}"
  echo -e "${box_color}│${padding}${PING_STATUS}${padding}${reset_color}"
  if [ "${ENABLE_PARALLEL}" = true ] || [ "${ENABLE_CACHING}" = true ]; then
    echo -e "${box_color}│${padding}Parallel DNS: ${PARALLEL_STATUS}${padding}${reset_color}"
    echo -e "${box_color}│${padding}DNS Caching: ${CACHING_STATUS}${padding}${reset_color}"
  fi
  echo -e "${box_color}├──────────────────────────────────────────────┤${reset_color}"
  echo -e "${box_color}│${padding}Check count: ${count}${padding}${reset_color}"
  echo -e "${box_color}│${padding}Loop Delay: ${LOOP_DELAY} seconds${padding}${reset_color}"
  echo -e "${box_color}└──────────────────────────────────────────────┘${reset_color}"
}

# Countdown before the main loop
for i in {5..0}; do
  echo "Checking started in $i seconds..."
  sleep 1
done
clear

# Main loop
while true; do
  check
  ((count++))  # Increment the counter
  sleep "${LOOP_DELAY}"
done

exit 0
