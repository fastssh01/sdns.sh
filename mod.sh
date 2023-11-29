#!/bin/bash

# Color Variables
border_color="\e[95m"
success_color="\e[92m"
fail_color="\e[91m"
header_color="\e[96m"
reset_color="\e[0m"

clear

function end_script() {
  exit 0
}

trap end_script 2 15

validate_input() {
  local input="$1"
  if [[ ! "$input" =~ ^[5-9]$|^1[0-5]$ ]]; then
    echo -e "\e[1;31mInvalid input. Using default loop delay of 5 seconds.\e[0m"
  else
    LOOP_DELAY=$input
  fi
}

get_custom_delay() {
  echo -e "\e[1;37mEnter custom loop delay in seconds \e[1;33m(5-15):\e[0m "
  read -r custom_delay
  validate_input "$custom_delay"
}

set_loop_delay() {
  echo -e "\e[1;37mWould you like to change the loop delay? \e[1;36m[y/n]:\e[0m "
  read -r change_delay
  if [[ "$change_delay" == "y" ]]; then
    get_custom_delay
  fi
}

initialize_variables() {
  LOOP_DELAY=5
  set_loop_delay
}

# ... (rest of the script)

check() {
  echo -e "${border_color}â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€${reset_color}"
  echo -e "${border_color}â”‚${header_color}DNS Status Check Results${reset_color}"
  echo -e "${border_color}â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€${reset_color}"

  for dns_ip in "${DNS_IPS[@]}"; do
    for name_server in "${NAME_SERVERS[@]}"; do
      # Check port 53 compatibility
      if nc -z -w 1 "$dns_ip" 53; then
        # Port 53 is open, proceed with DNS query
        result=$(timeout 5 ${_DIG} "@${dns_ip}" "${name_server}" +short)
        if [ $? -eq 0 ]; then
          STATUS="${success_color}Success${reset_color}"
        else
          STATUS="${fail_color}Failed${reset_color}"
        fi
      else
        # Port 53 is not open
        STATUS="${fail_color}Port 53 not reachable${reset_color}"
      fi

      echo -e "${border_color}â”‚${reset_color}DNS IP: ${dns_ip}  NameServer: ${name_server}  Status: ${STATUS}"
    done
  done

  echo -e "${border_color}â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€${reset_color}"
  echo -e "${border_color}â”‚${header_color}Check count: ${count}  Loop Delay: ${LOOP_DELAY} seconds${reset_color}"
  echo -e "${border_color}â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜${reset_color}"
}
