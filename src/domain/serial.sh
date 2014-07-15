#!/usr/bin/env bash
set -e

enableScreenshot=false
[[ ("$1" == "--screenshot") && ("$2" == "true") ]] && enableScreenshot=true

while read domain; do
	"${BASH_SOURCE%/*}/single.sh" "$domain" --screenshot "$enableScreenshot"
done
