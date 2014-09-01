#!/usr/bin/env bash
set -e

url="$1"

timestamp=$(date -u +%FT%TZ | tr -d ':')

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

getDomain(){
	cut -d'/' -f 3 | cut -d':' -f 1
}

domain="$(echo "$url" | getDomain)"
outdir="./$domain"
outfilebase="$domain.$timestamp"
outpathhar="$outdir/$outfilebase.har"
outpathpng="$outdir/$outfilebase.png"

mkdir -p "$outdir"

result=$("${BASH_SOURCE%/*}/../get/har.sh" "$url" --screenshot "$enableScreenshot")

if [[ $enableScreenshot == true ]]
then
	echo "$result" | jq --raw-output '.screenshot' | base64 --decode > "$outpathpng"
fi

echo "$result" | jq 'del(.screenshot)' > "$outpathhar"
