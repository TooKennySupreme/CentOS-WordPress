#!/bin/bash
# Calls PHP script to get CloudFlare domains where $1 is the email and $2 is the API key
result=($( php -f /usr/local/src/gigabyteio/cloudflare/get-domains.php $1 $2 ))
for i in "${result[@]}"
do
        echo $i
done
