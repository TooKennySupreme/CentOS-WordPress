<?php

$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_load_all($domain);
for ($i = 0; $i < $response->response->recs->count; $i++) {
        if($i != 0) {echo " ";}
        echo $response->response->recs->objs[$i]->rec_id;
}
