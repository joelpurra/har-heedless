#!/bin/bash
set -e

cd "$(dirname $0)"

url="$1"
phantomExecutable="phantomjs"
phantomPath=$(which "$phantomExecutable")
phantomDir=$(dirname "$phantomPath")
phantomRelativeLink=$(readlink "$phantomPath")
phantomRealpath=`echo $phantomDir/$phantomRelativeLink`
phantomRealdir=$(dirname "$phantomRealpath")
netsniffJs="$phantomRealdir/../share/phantomjs/examples/netsniff.js"
executionErrorHAR="./execution-error.har"

result=$(phantomjs "$netsniffJs" "$url")

if [[ $? == 0 ]]; then
	echo "$result"
else
	cat "$executionErrorHAR" | jq --arg url "$url" --arg error "$result" '. | .log.comment = "There was an error downloading \($url)\n\($error)"'
fi

cd - > /dev/null