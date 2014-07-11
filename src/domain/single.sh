#!/usr/bin/env bash
set -e

domain="$1"
timestamp=$(date -u +%FT%TZ | tr -d ':')
url="http://$domain/"
outdir="./$domain"
outfile="$domain.$timestamp.har"
outpath="$outdir/$outfile"

mkdir -p "$outdir"

"${BASH_SOURCE%/*}/../get/har.sh" "$url" > "$outpath"
