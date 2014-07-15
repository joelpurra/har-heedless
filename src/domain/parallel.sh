#!/usr/bin/env bash
set -e

domainsfile="$1"

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

counter=0
parallelLimit=100

timestamp(){
	now=$(date -u +%FT%TZ)
	echo "$now"
}

while read domain; do
	"${BASH_SOURCE%/*}/single.sh" "$domain" --screenshot "$enableScreenshot" &
	((counter++))

	for i in $(seq 1 "$((parallelLimit-1))"); do
		read domain && "${BASH_SOURCE%/*}/single.sh" "$domain" --screenshot "$enableScreenshot" &
		((counter++))
	done
	wait
	echo -n "$counter - "
	timestamp
done < "$domainsfile"
