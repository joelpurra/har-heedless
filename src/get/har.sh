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

phantomjs "$netsniffJs" "$url"

cd - > /dev/null