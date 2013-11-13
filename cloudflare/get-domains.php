<?php

$email = $argv[1];
$apikey = $argv[2];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->zone_load_multi();
for ($i = 0; $i < $response->response->zones->count; $i++) {
        if($i != 0) {echo " ";}
        echo $response->response->zones->objs[$i]->zone_name;
}
