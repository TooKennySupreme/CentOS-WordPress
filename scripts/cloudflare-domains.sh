#!/bin/bash
# Deletes all records and points records to IP address
# ./cloudflare-domains.sh e-mail api-key type name content
githubid=gigabyteio
zero=0
google_apps_cnames=0
github_cname=0
tumblr_cname=0
bitbucket_cname=0
blogger_cname=1
google_apps_mx=0
google_apps_srv=0
ttl=3600 # Add this in
direct_connect=0
result=($( php -f /usr/local/src/gigabyteio/cloudflare/get-domains.php $1 $2 ))
total_sites=${#result[@]} # might be useful
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
        if [[ $google_apps_cnames -eq $zero ]]; then
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME calendar ghs.googlehosted.com ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing drive.$i to Google Apps: $j$(tput sgr0)"
                        echo $j
                done
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME drive ghs.googlehosted.com ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing drive.$i to Google Apps: $j$(tput sgr0)"
                        echo $j
                done
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME mail ghs.googlehosted.com ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing mail.$i to Google Apps: $j$(tput sgr0)"
                        echo $j
                done
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME sites ghs.googlehosted.com ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing sites.$i to Google Apps: $j$(tput sgr0)"
                        echo $j
                done
        fi
        if [[ $github_cname -eq $zero ]]; then
                #https://help.github.com/articles/setting-up-a-custom-domain-with-pages $githubid.github.io
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME github $githubid.github.io ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing github.$i to $githubid.github.io: $j$(tput sgr0)"
                        echo $j
                done
        fi
        if [[ $tumblr_cname -eq $zero ]]; then
                #http://www.tumblr.com/docs/en/custom_domains
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME tumblr domains.tumblr.com ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing tumblr.$i to domains.tumblr.com: $j$(tput sgr0)"
                        echo $j
                done
        fi
        if [[ $direct_connect -eq $zero ]]; then
                #http://www.tumblr.com/docs/en/custom_domains
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME direct $i ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing direct.$i to $i with Cloudflare disabled: $j$(tput sgr0)"
                        echo $j
                done
        fi
        if [[ $bitbucket_cname -eq $zero ]]; then
                #Bitbucket
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME bitbucket bitbucket.org ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing bitbucket.$i to bitbucket.org: $j$(tput sgr0)"
                        echo $j
                done
        fi
        if [[ $blogger_cname -eq $zero ]]; then
                #Blogger
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME blogger ghs.google.com ))
                for j in "${create_status[@]}"
                do
                        if [ $j = success ]; then
                        j = "$(tput bold)$(tput setaf 2)$j$(tput sgr0)"
                        else
                        j = "$(tput bold)$(tput setaf 1)$j$(tput sgr0)"
                        fi
                        echo "* $(tput setaf 6)Pointing blogger.$i to ghs.google.com: $j$(tput sgr0)"
                        echo $j
                done
        fi
        if [[ $google_apps_mx -eq $zero ]]; then
        #Create Google Apps mail MX records
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ASPMX.L.GOOGLE.COM "1" ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ALT1.ASPMX.L.GOOGLE.COM "5" ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ALT2.ASPMX.L.GOOGLE.COM "5" ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ASPMX2.GOOGLEMAIL.COM "10" ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ASPMX3.GOOGLEMAIL.COM "10" ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        fi
        if [[ $google_apps_srv -eq $zero ]]; then
        # Creating SRV records for Google Apps chat compatibility
        # What is Piro?
        create_srv_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-srv-record.php $1 $2 $i SRV $i "3600" "1" "1" _xmpp-client thebestsites.com tcp "0" "5222" talk.l.google.com ))
               for j in "${create_status[@]}"
               do
                       echo $j
              done
        fi
        #if [[ $google_apps_spf -eq $zero ]]; then
        #fi
#v=spf1 a include:_spf.google.com ~all
        # Add GigabyteIO label
        create_gigatxt_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i TXT gigabyteio "Powered by GigabyteIO (http://gigabyte.io/)" ))
                for j in "${create_status[@]}"
                do
                        echo $j
                done
        
done
# http://www.olark.com/gtalk/check_srv
# https://support.google.com/a/answer/112038 < --- Domain verify stuff from Google
# Github stuff from github Github API automatic setup
# https://support.google.com/a/answer/174124?hl=en&ref_topic=2752442 < -- DKIM stuff email verification
