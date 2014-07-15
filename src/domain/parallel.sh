#!/usr/bin/env bash
set -e

parallelLimit="${1:-10}"

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

while read domain; do
	"${BASH_SOURCE%/*}/single.sh" "$domain" --screenshot "$enableScreenshot" &

	for i in $(seq 1 "$((parallelLimit-1))"); do
		read domain && "${BASH_SOURCE%/*}/single.sh" "$domain" --screenshot "$enableScreenshot" &
	done
	wait
done
