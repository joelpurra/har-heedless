 #!/usr/bin/env bash
set -e

[[ ! `which phantomjs` ]] && echo "phantomjs is required"
[[ ! `which jq` ]] && echo "jq is required"

url="$1"
netsniffJs="${BASH_SOURCE%/*}/netsniff.js"
executionErrorHAR="${BASH_SOURCE%/*}/execution-error.har"

result=$(phantomjs "$netsniffJs" "$url")

if [[ $? == 0 ]]; then
	echo "$result"
else
	cat "$executionErrorHAR" | jq --arg url "$url" --arg error "$result" '. | .log.comment = "There was an error downloading \($url)\n\($error)"'
fi
