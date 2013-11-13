<?php

$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
$type = $argv[4];
$name = $argv[5];
$content = $argv[6];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_new("$domain", "$type", "$name", "$content");
var_dump($response);
