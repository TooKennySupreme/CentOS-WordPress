# CentOS WordPress
This started as a simple wrapper shell script for [CentminMod](http://centminmod.com/) but has evolved into a bit more. It was built and tested with a 2GB [Digital Ocean VPS](https://www.digitalocean.com/?refcode=751743d45e36) VPS. CentOS WordPress adds a bleeding-edge web server software stack to your CentOS VPS.
## Features
+ Compiles software from source
+ Caches WordPress into RAM
+ Intelligently configures server based on hardware
+ Best security practices
+ Bug fixes to CentminMod
## Instructions
1. Instructions
2. Set up a CentOS VPS (we built and tested CentOS WordPress with a 2GB 64-bit CentOS 6.4 [Digital Ocean VPS](https://www.digitalocean.com/?refcode=751743d45e36)
3. Log into the VPS with PuTTY (or another SSH client)
4. Enter `bash <(curl -s https://raw.github.com/GigabyteIO/CentOS-WordPress/master/install.sh)`
5. Follow the prompts and prosper
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
