<?php

$email = $argv[1];
$apikey = $argv[2];
$domain = $argv[3];
$security = $argv[4];
$cache = $argv[5];
$ipv6 = $argv[6];
$rocket = $argv[7]; # Recommended by google
$minify = $argv[8]; # Disabled cloudflare

#sec_lvl($domain, $mode)
#help|high|med|low|eoff
#cache_lvl($domain, $mode)
#agg|basic
# 0 for no IPv6
#ipv46($domain, $mode)
#rocket loader 0 = off, a = automatic, m = manual
#async($domain, $mode)
# turn on minify 1|0
#minify($domain, $mode)
#0 = off
#1 = JavaScript only
#2 = CSS only
#3 = JavaScript and CSS
#4 = HTML only
#5 = JavaScript and HTML
#6 = CSS and HTML
#7 = CSS, JavaScript, and HTML
require( dirname(__FILE__) . '/cloudflare-api.php' );

$cf = new cloudflare_api("$email", "$apikey");
$response = $cf->sec_lvl($domain, $security);
echo $response->result;
$response = $cf->cache_lvl($domain, $cache);
echo $response->result;
$response = $cf->ipv6($domain, $ipv6);
echo $response->result;
$response = $cf->async($domain, $rocket);
echo $response->result;
$minify = $cf->minify($domain, $minify);
echo $response->result;
