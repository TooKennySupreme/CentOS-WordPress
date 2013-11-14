<?php
# email apikey domain priority service servicename protocol weight port target
$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
#$type = "SRV";
$name = $argv[3];
$content = $argv[3];
#$ttl = "3600"; # Recommended by google
#$mode = "0"; # Disabled cloudflare
$priority = $argv[4];
$service = $argv[5];
$srvname = $argv[6];
$protocol = $argv[7];
$weight = $argv[8];
$port = $argv[9];
$target = $argv[10];


require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_new("$domain", 'SRV', "$name", "", '3600', "", "$priority", "$service", "$srvname", "$protocol", "$weight", "$port", "$target");
#echo json_encode($response); not tested
#var_dump($response);
print_r($response);
