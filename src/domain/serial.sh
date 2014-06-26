 #!/usr/bin/env bash
set -e

domainsfile="$1"

while read domain; do
  "${BASH_SOURCE%/*}/single.sh" $domain
done < "$domainsfile"
