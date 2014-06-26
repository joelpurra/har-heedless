 #!/usr/bin/env bash
set -e

[[ ! `which phantomjs` ]] && { echo "phantomjs is required"; exit 1; }
[[ ! `which jq` ]] && { echo "jq is required"; exit 1; }

url="$1"
netsniffJs="${BASH_SOURCE%/*}/netsniff.js"
heedlessBaseHAR="${BASH_SOURCE%/*}/heedless-base.har"

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

# Check and save exit code, as output depends on it.
set +e
result=$(phantomjs "$netsniffJs" "$url")
phantomjsExitStatus=$?
set -e

if [[ $phantomjsExitStatus == 0 ]]; then
	echo "$result"
else
	cat "$heedlessBaseHAR" | jq --arg url "$url" --arg error "$result" "$addErrorMessage"
fi
