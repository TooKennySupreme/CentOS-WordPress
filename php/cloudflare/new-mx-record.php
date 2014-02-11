<?php

$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
# Types include: A/CNAME/MX/TXT/SPF/AAAA/NS/SRV/LO
$type = $argv[4];
$name = $argv[5];
$content = $argv[6];
$weight = $argv[7];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_new("$domain", "$type", "$name", "$content", "3600", "", "$weight");
echo $response->result;
