#!/usr/bin/env bash
set -e

domainsfile="$1"

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

while read domain; do
	"${BASH_SOURCE%/*}/single.sh" "$domain" --screenshot "$enableScreenshot"
done < "$domainsfile"
