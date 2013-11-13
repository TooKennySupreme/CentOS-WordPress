<?php

$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->rec_load_all($domain);
#for ($i = 0; $i < $response->response->zones->count; $i++) {
#        if($i != 0) {echo " ";}
#        echo $response->response->zones->objs[$i]->zone_name;
#        echo " ";
#        echo $response->response->zones->objs[$i]->zone_id;
}
var_dump($response);
 #rec_load_all($domain)
