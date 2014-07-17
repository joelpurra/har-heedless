#!/usr/bin/env bash
set -e

parallelLimit="${1:-10}"

enableScreenshot=false
[[ ("$2" == "--screenshot") && ("$3" == "true") ]] && enableScreenshot=true

cat | parallel --jobs "$parallelLimit" --load "80%" --line-buffer "echo \"{}\"; \"${BASH_SOURCE%/*}/single.sh\" \"{}\" --screenshot \"$enableScreenshot\";"

