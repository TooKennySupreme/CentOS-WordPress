# CentOS WordPress
**CentOS WordPress by GigabyteIO** is an installer for [CentminMod](http://centminmod.com/) (tested with and built for a [Digital Ocean VPS](https://www.digitalocean.com/?refcode=751743d45e36)). CentOS WordPress adds a *bleeding-edge web server stack* to your CentOS-based VPS.

## Features
+ Automatically configures your DNS with the Cloudflare API
+ Easy installation and management
+ Compiles software from source
+ Caches WordPress into RAM
+ Intelligently configures server based on hardware
+ Best security practices
+ Bug fixes to CentminMod

## Instructions
1. Set up a CentOS VPS (we built and tested CentOS WordPress with a 2GB 64-bit CentOS 6.4 [Digital Ocean VPS](https://www.digitalocean.com/?refcode=751743d45e36)
2. Log into the VPS with PuTTY (or another SSH client)
3. Enter `bash <(curl -s https://raw.github.com/GigabyteIO/CentOS-WordPress/master/install.sh)`
4. Follow the prompts and prosper

## Benchmarks
| Future test        | Other thing           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

## Technology Used
+ Nginx + FastCGICache - Bundles arguably the fastest web server with a server level static file caching
+ PHP-FPM + APC - Provides PHP support to Nginx with opcode caching
+ Memcached Server and Client - Distributed memory caching system (for cloud networks)
+ Pagespeed - Google's bleeding-edge website compression/optimization software
+ MariaDB - MySQL performance fork
+ Multi-Threaded Compression - Improves website load times by compressing files aggressively
+ CSF Firewall - Manages the firewall and uses real-time monitoring to protect against attacks
+ Automatic WordPress Installer - Custom WordPress installer for boss websites
