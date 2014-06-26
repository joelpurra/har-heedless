 #!/usr/bin/env bash
set -e

domainsfile="$PWD/$1"

cd "$(dirname $0)"

counter=0
parallelLimit=100

timestamp(){
	now=$(date -u +%FT%TZ)
	echo "$now"
}

while read domain; do
	./single.sh "$domain" &
	((counter++))

	for i in $(seq 1 "$((parallelLimit-1))"); do
		read domain && ./single.sh "$domain" &
		((counter++))
   done
   wait
   echo -n "$counter - "
   timestamp
done < "$domainsfile"

cd - > /dev/null