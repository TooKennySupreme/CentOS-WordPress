<?php
require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("8afbe6dea02407989af4dd4c97bb6e25");
$response = $cf->user_create("newuser@example.com", "newpassword", "", "someuniqueid");
echo json_encode($response)
