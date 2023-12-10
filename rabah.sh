#!/bin/bash

function endscript() {
  exit 1
}

trap endscript 2 15

# Function to perform DNS query and cache the result
perform_dns_query() {
  local result
  result="$(${_DIG} @${1} ${2} +short)"
  echo "$result" > "${CACHE_DIR}/${2}_${1}"
  echo "$result"
}

# Manually set configuration options
read -p "Enable caching? (y/n): " ENABLE_CACHING_CHOICE

case "${ENABLE_CACHING_CHOICE}" in
  [Yy]*)
    ENABLE_CACHING=true
    ;;
  *)
    ENABLE_CACHING=false
    ;;
esac

# Manually input DNS name servers
echo -e "\nEnter DNS Name Servers separated by ' ':\n"
read -a NAME_SERVERS

# Manually input DNS IPs
echo -e "\nEnter DNS IPs separated by ' ':\n"
read -a DNS_IPS

# ...

# Initialize the counter
count=1

check() {
  local success_color="\e[92m"  # Light green color
  local fail_color="\e[91m"     # Light red color
  local reset_color="\e[0m"     # Reset to default terminal color
  local padding="  "             # Padding for aesthetic
  local border_color="\e[96m"   # Light cyan color

  # Display the box-like structure
  echo -e "${border_color}┌───────────────────────────────${reset_color}"
  echo -e "${border_color}│ Iteration: ${count}${padding}${reset_color}"
  echo -e "${border_color}├───────────────────────────────${reset_color}"

  # Results
  for DI in "${DNS_IPS[@]}"; do
    for NS in "${NAME_SERVERS[@]}"; do
      result=$(${_DIG} @${DI} ${NS} +short)
      if [ -z "$result" ]; then
        STATUS="${success_color}Success${reset_color}"
      else
        STATUS="${fail_color}Failed${reset_color}"
      fi

      echo -e "${border_color}│ DNS IP: ${DI}${padding}${reset_color}"
      echo -e "${border_color}│ Status: ${STATUS}${padding}${reset_color}"
      echo -e "${border_color}├───────────────────────────────${reset_color}"
    done
  done

  # Check count and Loop Delay
  echo -e "${border_color}└───────────────────────────────${reset_color}"
  echo -e "${border_color} Check count: ${count}${padding}${reset_color}"
  echo -e "${border_color} Loop Delay: ${LOOP_DELAY} seconds${padding}${reset_color}"
}

countdown() {
  for i in {5..1}; do
    echo "Checking started in $i seconds..."
    sleep 1
  done
}

echo ""
echo "Begin...."
echo ""
countdown
clear

# Main loop
while true; do
  check
  ((count++))  # Increment the counter
  sleep $LOOP_DELAY
done

exit 0
