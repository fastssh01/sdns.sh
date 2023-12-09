#!/bin/bash

# Set your preferred DNS server
DNS_SERVER="8.8.8.8"

# Function to perform DNS query
perform_dns_query() {
  local result
  result=$(dig +stats +noquestion +nocomments +noauthority +noadditional +nocmd +nostats @$DNS_SERVER "$1")
  echo "$result"
}

# Function to display results in a box
display_results() {
  local domain=$1
  local result=$(perform_dns_query $domain)

  if [[ $result == *"Query time"* ]]; then
    echo -e "\e[92mDNS query for $domain was successful:\e[0m"
  else
    echo -e "\e[91mDNS query for $domain failed.\e[0m"
  fi

  # Output the results in a box
  echo -e "┌──────────────────────────────────────┐"
  echo -e "│ $result │"
  echo -e "└──────────────────────────────────────┘"
}

# Manual input for domain
echo -e "Enter the domain you want to query:"
read domain

# Perform DNS query and display results
display_results $domain
