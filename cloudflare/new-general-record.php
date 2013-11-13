<?php

$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
$name = $argv[4];
$content = $argv[5];
$weight = $argv[6];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_new($domain, $type, $id, $name, $content, $ttl, $mode, $piro, $service, $srvname, $protocol, $weight, $port, $target);
#php -f new-srv-record.php($1)
echo $response->result;
