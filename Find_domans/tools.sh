#!/bin/bash
while read dom; do 
	while read sub; do
		if host "$sub.$dom" &> /dev/null; then
			echo "$sub.$dom : Alive"
		fi
	done < subdomain.txt
done < domains.txt
