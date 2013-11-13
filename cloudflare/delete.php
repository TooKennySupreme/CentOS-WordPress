<?php

$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
$id = $argv[4];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->delete_dns_record($domain, $id);
echo $response->result;
