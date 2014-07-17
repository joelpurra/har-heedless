#!/usr/bin/env bash
set -e

domain="$1"
timestamp=$(date -u +%FT%TZ | tr -d ':')
url="http://$domain/"

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

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
