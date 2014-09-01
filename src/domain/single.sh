#!/usr/bin/env bash
set -e

prefix="$1"
shift

cat | sed "s_.*_$prefix&/_" | "${BASH_SOURCE%/*}/../url/single.sh" "$@"

