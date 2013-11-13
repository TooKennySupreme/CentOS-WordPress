<?php

$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
$name = $argv[4];
$content = $argv[5];
$weight = $argv[6];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_new("$domain", "SRV", "$name", "$content", "3600", "$weight", 1, 1);
echo $response->result;
