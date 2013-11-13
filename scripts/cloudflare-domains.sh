#!/bin/bash
# Deletes all records and points records to IP address
# ./cloudflare-domains.sh e-mail api-key type name content
result=($( php -f /usr/local/src/gigabyteio/cloudflare/get-domains.php $1 $2 ))
for i in "${result[@]}"
do
        records=($( php -f /usr/local/src/gigabyteio/cloudflare/get-records.php $1 $2 $i ))
        for j in "${records[@]}"
        do
                delete_status=($( php -f /usr/local/src/gigabyteio/cloudflare/delete.php $1 $2 $i $j ))
                for k in "${delete_status[@]}"
                do
                        echo $k
                done
        done
        create_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i $3 $4 $5 ))
done
