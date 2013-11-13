<?php

$email = $argv[1];
$apikey = $argv[2];
$domain
$type
$id
$record = $argv[3];
$data = $argv[4];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_edit();
//rec_edit($domain, $type, $id, $name, $content, $ttl = 1, $mode = 1, $piro = 1, $service = 1, $srvname = 1, $protocol = 1, $weight = 1, $port = 1, $target = 1)
