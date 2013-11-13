<?php
# Returns a list of zone names and IDs ( zone_name_1 zone_id_1 zone_name_2 .... zone_id_5435353453 )
$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
$id = $argv[4];

require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->delete_dns_record($domain, $id);
var_dump($response);
