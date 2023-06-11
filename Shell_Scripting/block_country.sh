#!/bin/bash

# Specify the country code you want to block
read -p "Enter country code you want to block :- " COUNTRY_CODE

# Define the URL for the IP range database
DATABASE_URL="https://www.ipdeny.com/ipblocks/data/countries/$COUNTRY_CODE.zone"

# Define the temporary file to store the downloaded IP ranges
TMP_FILE="/tmp/$COUNTRY_CODE.zone"

# Download the IP range database for the specified country
wget -O "$TMP_FILE" "$DATABASE_URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download the IP range database for $COUNTRY_CODE."
    exit 1
fi

# Block all incoming traffic from the specified country
while read -r IP_RANGE; do
    iptables -A INPUT -s "$IP_RANGE" -j DROP
done < "$TMP_FILE"

echo "Blocked all incoming traffic from $COUNTRY_CODE."

# Clean up the temporary file
rm "$TMP_FILE"

