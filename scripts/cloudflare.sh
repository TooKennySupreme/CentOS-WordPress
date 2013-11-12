#!/bin/bash

result=$( php -f /usr/local/src/gigabyteio/cloudflare/get-domains.php )
if [ "$result" = "" ] ; then
    echo "Nothing happened."
else 
    echo "$result received."
fi
