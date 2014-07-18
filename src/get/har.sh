#!/usr/bin/env bash
set -e

[[ ! `which phantomjs` ]] && { echo "phantomjs is required"; exit 1; }
[[ ! `which jq` ]] && { echo "jq is required"; exit 1; }

url="$1"

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

netsniffJs="${BASH_SOURCE%/*}/netsniff.js"
netsniffJsArguments=("$url" "--screenshot" "$enableScreenshot")
heedlessBaseHAR="${BASH_SOURCE%/*}/heedless-base.har"
timeoutAfter="90s"
timeoutMessage="Executing phantomjs timed out after $timeoutAfter."

timeoutExec="timeout"
if [[ -z $(which "$timeoutExec") ]]
then
	# Mac OS X GNU coreutils installed with homebrew
	timeoutExec="gtimeout"
fi

read -d '' addErrorMessage <<-'EOF' || true
.log.comment = "There was an error downloading \\($url)\\n\\($error)"
| .log.entries = [
	{
		request: {
			url: $url
		},
		comment: $error
	}
]
EOF

harError(){
	cat "$heedlessBaseHAR" | jq --arg url "$url" --arg error "$1" "$addErrorMessage"
}

# Check and save exit code, as output depends on it.
set +e
result=$("$timeoutExec" "$timeoutAfter" phantomjs "$netsniffJs" "${netsniffJsArguments[@]}")
phantomjsExitStatus=$?
set -e

if [[ $phantomjsExitStatus == 0 ]]; then
	echo "$result"
elif [[ $phantomjsExitStatus == 124 || $phantomjsExitStatus == 137 ]]; then
	harError "$timeoutMessage"
else
	harError "$result"
fi
