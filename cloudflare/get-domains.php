<?php

$apikey = $argv[1];
$email = $argv[2];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->zone_load_multi();
echo json_encode($response)
#rec_edit($domain, $type, $id, $name, $content, $ttl = 1, $mode = 1, $piro = 1, $service = 1, $srvname = 1, $protocol = 1, $weight = 1, $port = 1, $target = 1)
?>
