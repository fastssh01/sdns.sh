# ...

check(){
  local border_color="\e[95m"  # Light magenta color
  local success_color="\e[92m"  # Light green color
  local fail_color="\e[91m"    # Light red color
  local header_color="\e[96m"  # Light cyan color
  local reset_color="\e[0m"    # Reset to default terminal color
  local padding="  "            # Padding for aesthetic

  # Header
  echo -e "${border_color}â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤${reset_color}"
  echo -e "${border_color}â”‚${header_color}${padding}DNS Status Check Results${padding}${reset_color}"
  echo -e "${border_color}â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤${reset_color}"
  
  # Results
  for T in "${DNS_IPS[@]}"; do
    for R in "${NAME_SERVERS[@]}"; do
      result=$(${_DIG} @${T} ${R} +short +timeout=5)
      if [ -z "$result" ]; then
        STATUS="${success_color}Success${reset_color}"
      else
        STATUS="${fail_color}Failed${reset_color}"
      fi
      echo -e "${border_color}â”‚${padding}${reset_color}DNS IP: ${T}${padding}${reset_color}"
      echo -e "${border_color}â”‚${padding}NameServer: ${R}${padding}${reset_color}"
      echo -e "${border_color}â”‚${padding}Status: ${STATUS}${padding}${reset_color}"
    done
  done

  # Check count and Loop Delay
  echo -e "${border_color}â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤${reset_color}"
  echo -e "${border_color}â”‚${padding}${header_color}Check count: ${count}${padding}${reset_color}"
  echo -e "${border_color}â”‚${padding}Loop Delay: ${LOOP_DELAY} seconds${padding}${reset_color}"
 
  # Footer
  echo -e "${border_color}â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜${reset_color}"
}

# ...
