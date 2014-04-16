#!/bin/bash
set -e

cd "$(dirname $0)"

domain="$1"
timestamp=$(date -u +%FT%TZ | tr -d ':')
url="http://$domain/"
outdir="../../data/$domain"
outfile="$domain.$timestamp.har"
outpath="$outdir/$outfile"

mkdir -p "$outdir"

../get/har.sh "$url" > "$outpath"

cd - > /dev/null