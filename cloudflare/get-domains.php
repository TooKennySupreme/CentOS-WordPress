<?php

$email = $argv[1];
$apikey = $argv[2];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->zone_load_multi();
echo json_encode($response)
