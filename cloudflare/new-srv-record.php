<?php
# email apikey domain priority service servicename protocol weight port
$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
$type = "SRV";
$name = $argv[3];
$content = $argv[3];
$ttl = "3600"; # Recommended by google
$mode = "0"; # Disabled cloudflare
$service = $argv[4];
$srvname = $argv[5];
$protocol = $argv[6];
$weight = $argv[7];
$port = $argv[8];
$target = $argv[9];


require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_new($domain, $type, $name, $content, $ttl, $mode, $piro, $service, $srvname, $protocol, $weight, $port, $target);
echo $response->result;
