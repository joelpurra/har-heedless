#!/bin/bash
set -e

domainsfile="$PWD/$1"

cd "$(dirname $0)"

while read domain; do
  ./single.sh $domain
done < "$domainsfile"

cd - > /dev/null