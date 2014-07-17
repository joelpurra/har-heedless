#!/usr/bin/env bash
set -e

[[ -z `which parallel` || ! ($(parallel --version 2>/dev/null) =~ ^GNU.parallel.*) ]] && { echo "GNU parallel is required"; exit 1; }

parallelLimit="${1:-10}"

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

cat | parallel --jobs "$parallelLimit" --load "80%" --line-buffer "echo \"{}\"; \"${BASH_SOURCE%/*}/single.sh\" \"{}\" --screenshot \"$enableScreenshot\";"

