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
srv_ttl=3600 # one hour
a_ttl=604800 # one week
cname_ttl=86400 # one day
direct_connect=0
echo "* $(tput setaf 6)Getting server's public IP address using ifconfig.me$(tput sgr0)"
ip_address=$(curl ifconfig.me) #get public ip from ipconfig website
result=($( php -f /usr/local/src/gigabyteio/cloudflare/get-domains.php $1 $2 ))
total_sites=${#result[@]} # might be useful
for i in "${result[@]}"
do
        records=($( php -f /usr/local/src/gigabyteio/cloudflare/get-records.php $1 $2 $i ))
        for j in "${records[@]}"
        do
                delete_status=($( php -f /usr/local/src/gigabyteio/cloudflare/delete.php $1 $2 $i $j ))
                if [ $delete_status = success ]; then
                        delete_status="$(tput bold)$(tput setaf 2)$delete_status$(tput sgr0)"
                else
                        delete_status="$(tput bold)$(tput setaf 1)$delete_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Removing record ID $j from $i's zone file: $delete_status$(tput sgr0)"
        done
        # Create A name pointing to IP address
        create_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i A $i $ip_address ))
                if [ $create_status = success ]; then
                        create_status="$(tput bold)$(tput setaf 2)$create_status$(tput sgr0)"
                else
                        create_status="$(tput bold)$(tput setaf 1)$create_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Adding A record pointing $i to this server's IP address ($ip_address): $create_status$(tput sgr0)"
        # Create CNAME records
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME www $i ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing www.$i to $i: $create_cname_status$(tput sgr0)"
        if [[ $google_apps_cnames -eq $zero ]]; then
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME calendar ghs.googlehosted.com ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing calendar.$i to Google Apps: $create_cname_status$(tput sgr0)"
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME drive ghs.googlehosted.com ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing drive.$i to Google Apps: $create_cname_status$(tput sgr0)"
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME mail ghs.googlehosted.com ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing mail.$i to Google Apps: $create_cname_status$(tput sgr0)"
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME sites ghs.googlehosted.com ))
                 if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing sites.$i to Google Apps: $create_cname_status$(tput sgr0)"
        fi
        if [[ $github_cname -eq $zero ]]; then
                #https://help.github.com/articles/setting-up-a-custom-domain-with-pages $githubid.github.io
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME github $githubid.github.io ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing github.$i to $githubid.github.io: $create_cname_status$(tput sgr0)"
        fi
        if [[ $tumblr_cname -eq $zero ]]; then
                #http://www.tumblr.com/docs/en/custom_domains
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME tumblr domains.tumblr.com ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing tumblr.$i to domains.tumblr.com: $create_cname_status$(tput sgr0)"
        fi
        if [[ $direct_connect -eq $zero ]]; then
                #http://www.tumblr.com/docs/en/custom_domains
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME direct $i ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing direct.$i to $i with Cloudflare disabled: $create_cname_status$(tput sgr0)"
        fi
        if [[ $bitbucket_cname -eq $zero ]]; then
                #Bitbucket
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME bitbucket bitbucket.org ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing bitbucket.$i to bitbucket.org: $create_cname_status$(tput sgr0)"
        fi
        if [[ $blogger_cname -eq $zero ]]; then
                #Blogger
        create_cname_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i CNAME blogger ghs.google.com ))
                if [ $create_cname_status = success ]; then
                        create_cname_status="$(tput bold)$(tput setaf 2)$create_cname_status$(tput sgr0)"
                else
                        create_cname_status="$(tput bold)$(tput setaf 1)$create_cname_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Pointing blogger.$i to ghs.google.com: $create_cname_status$(tput sgr0)"
        fi
        if [[ $google_apps_mx -eq $zero ]]; then
        #Create Google Apps mail MX records
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ASPMX.L.GOOGLE.COM "1" ))
                if [ $create_mx_status = success ]; then
                        create_mx_status="$(tput bold)$(tput setaf 2)$create_mx_status$(tput sgr0)"
                else
                        create_mx_status="$(tput bold)$(tput setaf 1)$create_mx_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Adding mail server record for $i pointing to ASPMX.L.GOOGLE.COM with a priority of 1: $create_mx_status$(tput sgr0)"
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ALT1.ASPMX.L.GOOGLE.COM "5" ))
                 if [ $create_mx_status = success ]; then
                        create_mx_status="$(tput bold)$(tput setaf 2)$create_mx_status$(tput sgr0)"
                else
                        create_mx_status="$(tput bold)$(tput setaf 1)$create_mx_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Adding mail server record for $i pointing to ALT1.ASPMX.L.GOOGLE.COM with a priority of 5: $create_mx_status$(tput sgr0)"
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ALT2.ASPMX.L.GOOGLE.COM "5" ))
                if [ $create_mx_status = success ]; then
                        create_mx_status="$(tput bold)$(tput setaf 2)$create_mx_status$(tput sgr0)"
                else
                        create_mx_status="$(tput bold)$(tput setaf 1)$create_mx_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Adding mail server record for $i pointing to ALT2.ASPMX.L.GOOGLE.COM with a priority of 5: $create_mx_status$(tput sgr0)"
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ASPMX2.GOOGLEMAIL.COM "10" ))
                if [ $create_mx_status = success ]; then
                        create_mx_status="$(tput bold)$(tput setaf 2)$create_mx_status$(tput sgr0)"
                else
                        create_mx_status="$(tput bold)$(tput setaf 1)$create_mx_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Adding mail server record for $i pointing to ASPMX2.GOOGLEMAIL.COM with a priority of 10: $create_mx_status$(tput sgr0)"
        create_mx_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-mx-record.php $1 $2 $i MX $i ASPMX3.GOOGLEMAIL.COM "10" ))
                if [ $create_mx_status = success ]; then
                        create_mx_status="$(tput bold)$(tput setaf 2)$create_mx_status$(tput sgr0)"
                else
                        create_mx_status="$(tput bold)$(tput setaf 1)$create_mx_status$(tput sgr0)"
                        fi
                echo "* $(tput setaf 6)Adding mail server record for $i pointing to ASPMX3.GOOGLEMAIL.COM with a priority of 10: $create_mx_status$(tput sgr0)"
        fi
        if [[ $google_apps_srv -eq $zero ]]; then
        # Creating SRV records for Google Apps chat compatibility
        service=( '_xmpp-server' '_xmpp-server' '_xmpp-server' '_xmpp-server' '_xmpp-server' '_jabber' '_jabber' '_jabber' '_jabber' '_jabber' '_xmpp-client' '_xmpp-client' '_xmpp-client' '_xmpp-client' '_xmpp-client' )
        priority=( "5" "20" "20" "20" "20" "5" "20" "20" "20" "20" "5" "20" "20" "20" "20" )
        weight="0"
        protocol="tcp"
        srvname="googleapps"
        port=( '5269' '5269' '5269' '5269' '5269' '5269' '5269' '5269' '5269' '5269' '5222' '5222' '5222' '5222' '5222' )
        target=( 'xmpp-server.l.google.com' 'alt1.xmpp-server.l.google.com' 'alt2.xmpp-server.l.google.com' 'alt3.xmpp-server.l.google.com' 'alt4.xmpp-server.l.google.com' 'xmpp-server.l.google.com' 'alt1.xmpp-server.l.google.com' 'alt2.xmpp-server.l.google.com' 'alt3.xmpp-server.l.google.com' 'alt4.xmpp-server.l.google.com' 'xmpp.l.google.com' 'alt1.xmpp.l.google.com' 'alt2.xmpp.l.google.com' 'alt3.xmpp.l.google.com' 'alt4.xmpp.l.google.com' )
        for ((n=0;n<15;n++))
        do
        # email apikey domain priority service servicename protocol weight port
        create_srv_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-srv-record.php $1 $2 $i ${priority[$n]} ${service[$n]} $srvname $protocol $weight ${port[$n]} ${target[$n]} ))
                if [ $create_srv_status = success ]; then
                        create_srv_status="$(tput bold)$(tput setaf 2)$create_srv_status$(tput sgr0)"
                else
                        create_srv_status="$(tput bold)$(tput setaf 1)$create_srv_status$(tput sgr0)"
                fi
                echo "* $(tput setaf 6)Adding SRV record for $i (TTL: $srv_ttl Service: ${service[$n]} Protocol: $protocol Priority: ${priority[$n]} Weight: $weight Port: ${port[$n]} Target: $(${target[$i]}) ):  $create_srv_status$(tput sgr0)"
                #(TTL: $srv_ttl Service: ${service[$n]} $protocol Priority: ${priority[$n]} Weight: $weight Port: ${port[$n]} Target: ${target[$i]})
        done
        fi
        #if [[ $google_apps_spf -eq $zero ]]; then
        #fi
#v=spf1 a include:_spf.google.com ~all
        # Add GigabyteIO label
        create_gigatxt_status=($( php -f /usr/local/src/gigabyteio/cloudflare/new-record.php $1 $2 $i TXT gigabyteio "Powered by GigabyteIO (http://gigabyte.io/)" ))
                if [ $create_gigatxt_status = success ]; then
                        create_gigatxt_status="$(tput bold)$(tput setaf 2)$create_gigatxt_status$(tput sgr0)"
                else
                        create_gigatxt_status="$(tput bold)$(tput setaf 1)$create_gigatxt_status$(tput sgr0)"
                fi
                echo "* $(tput setaf 6)Adding GigabyteIO text label: $create_gigatxt_status$(tput sgr0)"
        security_level=med #help|high|med|low|eoff
        cache_level=agg #agg|basic
        ipv6_mode=0 #0\1
        rocket_load=a #0|a|m    a =  automatic/ m = manual
        minify=7 #0 off | 1 js only | 2 css only | 3 js + css | 4 html only | 5 js + html | 6 css + html | 7 css js html
        adjust_settings_status=($( php -f /usr/local/src/gigabyteio/cloudflare/change-settings.php $1 $2 $i $security_level $cache_level $ipv6_mode $rocket_load $minify ))
                if [ $adjust_settings_status = successsuccesssuccesssuccesssuccess ]; then
                        adjust_settings_status=success
                        adjust_settings_status="$(tput bold)$(tput setaf 2)$adjust_settings_status$(tput sgr0)"
                else
                        adjust_settings_status=FAILED
                        adjust_settings_status="$(tput bold)$(tput setaf 1)$adjust_settings_status$(tput sgr0)"
                fi
                echo "* $(tput setaf 6)Adjusting settings (Security-Level: Medium, Cache-Level: Aggressive, IPv6-Support: Off, Rocket-Loading: Automatic, Minify: HTML/JS/CSS): $adjust_settings_status$(tput sgr0)"

done
# http://www.olark.com/gtalk/check_srv
# https://support.google.com/a/answer/112038 < --- Domain verify stuff from Google
# Github stuff from github Github API automatic setup
# https://support.google.com/a/answer/174124?hl=en&ref_topic=2752442 < -- DKIM stuff email verification
