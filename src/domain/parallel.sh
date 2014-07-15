#!/usr/bin/env bash
set -e

domainsfile="$1"

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

parallelLimit=100

while read domain; do
	"${BASH_SOURCE%/*}/single.sh" "$domain" --screenshot "$enableScreenshot" &

	for i in $(seq 1 "$((parallelLimit-1))"); do
		read domain && "${BASH_SOURCE%/*}/single.sh" "$domain" --screenshot "$enableScreenshot" &
	done
	wait
done < "$domainsfile"
