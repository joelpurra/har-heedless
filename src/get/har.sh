 #!/usr/bin/env bash
set -e

[[ ! `which phantomjs` ]] && echo "phantomjs is required"

cd "$(dirname $0)"

url="$1"
netsniffJs="./netsniff.js"
executionErrorHAR="./execution-error.har"

result=$(phantomjs "$netsniffJs" "$url")

if [[ $? == 0 ]]; then
	echo "$result"
else
	cat "$executionErrorHAR" | jq --arg url "$url" --arg error "$result" '. | .log.comment = "There was an error downloading \($url)\n\($error)"'
fi

cd - > /dev/null