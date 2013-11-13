#!/bin/bash
# Deletes all records and points records to IP address
# ./cloudflare-domains.sh e-mail api-key type name content
githubid=gigabyteio
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
        # Create A name pointing to IP address
        create_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i A $i $3 ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        # Create CNAME records
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME www $i ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME calendar ghs.googlehosted.com ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
                
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME drive ghs.googlehosted.com ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME mail ghs.googlehosted.com ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME sites ghs.googlehosted.com ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
                #https://help.github.com/articles/setting-up-a-custom-domain-with-pages $githubid.github.io
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME github $githubid.github.io ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
                #http://www.tumblr.com/docs/en/custom_domains
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME tumblr domains.tumblr.com ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
                #Bitbucket
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME bitbucket bitbucket.org ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
                #Blogger
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME blogger ghs.google.com ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        #Create Google Apps mail MX records
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX @ ASPMX.L.GOOGLE.COM 1 ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX @ ALT1.ASPMX.L.GOOGLE.COM 5 ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX @ ALT2.ASPMX.L.GOOGLE.COM 5 ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX @ ASPMX2.GOOGLEMAIL.COM 10 ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX @ ASPMX3.GOOGLEMAIL.COM 10 ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        # Creating SRV records for Google Apps chat compatibility
        create_srv_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-srv-record.php $1 $2 $i MX @ ASPMX3.GOOGLEMAIL.COM 10 ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
#v=spf1 a include:_spf.google.com ~all
        # Add GigabyteIO label
        create_gigatxt_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i TXT gigabyteio "Powered by GigabyteIO (http://gigabyte.io/)" ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        
done







; SRV
_xmpp-server._tcp.@	1	IN	SRV	20	0	5269	alt4.xmpp-server.l.google.com
_xmpp-server._tcp.@	1	IN	SRV	5	0	5269	xmpp-server.l.google.com
_xmpp-server._tcp.@	1	IN	SRV	20	0	5269	alt2.xmpp-server.l.google.com
_xmpp-server._tcp.@	1	IN	SRV	20	0	5269	alt3.xmpp-server.l.google.com
_xmpp-server._tcp.@	1	IN	SRV	20	0	5269	alt1.xmpp-server.l.google.com
# https://support.google.com/a/answer/112038 < --- Domain verify stuff from Google
# Github stuff from github
# https://support.google.com/a/answer/174124?hl=en&ref_topic=2752442 < -- DKIM stuff email verification
