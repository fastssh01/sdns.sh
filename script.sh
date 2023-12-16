#!/bin/bash

# Check if client is already downloaded
if [[ ! -e dnstt-client.so ]]; then
    yes| termux-setup-storage > /dev/null 2>&1
else
    echo "SlowDNS Client already installed."
    rm -f script.sh
    exit 1
fi

# Function to check the CPU architecture
get_architecture() {
    case $(uname -m) in
        aarch64*) echo "aarch64" ;;
        armv8l*) echo "armv8l" ;;
        x86) echo "x86" ;;
        armv7a) echo "armv7a" ;;
        x86_64) echo "x86_64" ;;
        *) echo "unknown" ;;
    esac
}

# Get the current CPU architecture
architecture=$(get_architecture)

# Check the architecture and download the file accordingly
case $architecture in
    "aarch64")
        url="https://devsciple.com/dnstt/aarch64/dnstt-client.so"
        ;;
    "armv8l")
    url="https://devsciple.com/dnstt/armv8l/dnstt-client.so"
        ;;
    "x86")
        url="https://devsciple.com/dnstt/i686/dnstt-client.so"
        ;;
    "armv7a")
        url="https://devsciple.com/dnstt/armv7a/dnstt-client.so"
        ;;
    "x86_64")
        url="https://devsciple.com/dnstt/x86_64/dnstt-client.so"
        ;;
    *)
        echo "Unsupported architecture: $architecture."
        rm -f script.sh
        exit 1
        ;;
esac

# Download the file using curl
curl -LOk -s $url
chmod +x dnstt-client.so

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "SlowDNS Client installed successfully."
else
    echo "SlowDNS Client installation failed."
fi

rm -f script.sh
