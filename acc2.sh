#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

echo -e "Enter DNS IPs separated by ' ': "
read -a DNS_IPS

echo -e "Enter Your NameServers separated by ' ': "
read -a NAME_SERVERS

LOOP_DELAY=5
echo -e "Current loop delay is ${LOOP_DELAY} seconds."
echo -e "Would you like to change the loop delay? [y/n]: "
read -r change_delay

if [[ "$change_delay" == "y" ]]; then
  echo -e "Enter custom loop delay in seconds (5-15): "
  read -r custom_delay
  if [[ "$custom_delay" =~ ^[5-9]$|^1[0-5]$ ]]; then
    LOOP_DELAY=$custom_delay
  else
    echo -e "Invalid input. Using default loop delay of ${LOOP_DELAY} seconds."
  fi
fi

# Prompt user for DNS lookup tool
echo -e "Choose DNS lookup tool:"
echo -e "1. nslookup"
echo -e "2. dig"
echo -e "3. host"
read -r dns_lookup_option

case $dns_lookup_option in
  1)
    DNS_LOOKUP="nslookup"
    ;;
  2)
    DNS_LOOKUP="dig"
    ;;
  3)
    DNS_LOOKUP="host"
    ;;
  *)
    echo -e "Invalid option. Using default DNS lookup tool (dig)."
    DNS_LOOKUP="dig"
    ;;
esac

# Initialize the counter
count=1

# Function to check DNS status
check() {
  local success_color="Success"
  local fail_color="Failed"

  # Header
  echo "┌─────────────────────────────────────┐"
  echo "│          DNS Status Check           │"
  echo "├─────────────────────────────────────┤"
  
  # Results
  for T in "${DNS_IPS[@]}"; do
    for R in "${NAME_SERVERS[@]}"; do
      result=$($DNS_LOOKUP @${T} ${R} +short)
      if [ -z "$result" ]; then
        STATUS="${success_color}"
      else
        STATUS="${fail_color}"
      fi
      echo "│ DNS IP: ${T}"
      echo "│ NameServer: ${R}"
      echo "│ Status: ${STATUS}"
      
      # Perform ping to nameserver
      if ping_result=$(ping -c 3 -W 2 ${R} 2>&1); then
        nameserver_status="${success_color}"
      else
        nameserver_status="${fail_color}"
        echo "│ Ping to NameServer: ${nameserver_status}"
        echo "│ Error: ${ping_result}"
      fi

      # Perform ping to DNS IP
      if ping_result=$(ping -c 3 -W 2 ${T} 2>&1); then
        dnsip_status="${success_color}"
      else
        dnsip_status="${fail_color}"
        echo "│ Ping to DNS IP: ${dnsip_status}"
        echo "│ Error: ${ping_result}"
      fi
    done
  done

  # Check count and Loop Delay
  echo "├─────────────────────────────────────┤"
  echo "│ Check count: ${count}"
  echo "│ Loop Delay: ${LOOP_DELAY} seconds"
 
  # Footer
  echo "└─────────────────────────────────────┘"
}

countdown() {
    for i in 5 4 3 2 1 0; do
        echo "Checking started in $i seconds..."
        sleep 1
    done
}

echo ""
echo ""
echo "Begin...."
echo ""
echo ""
countdown
clear

# Main loop
while true; do
  check
  ((count++))  # Increment the counter
  sleep $LOOP_DELAY
done
