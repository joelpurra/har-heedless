#!/usr/bin/env bash
set -e

domainsfile="$1"

counter=0
parallelLimit=100

timestamp(){
	now=$(date -u +%FT%TZ)
	echo "$now"
}

while read domain; do
	"${BASH_SOURCE%/*}/single.sh" "$domain" &
	((counter++))

	for i in $(seq 1 "$((parallelLimit-1))"); do
		read domain && "${BASH_SOURCE%/*}/single.sh" "$domain" &
		((counter++))
   done
   wait
   echo -n "$counter - "
   timestamp
done < "$domainsfile"
