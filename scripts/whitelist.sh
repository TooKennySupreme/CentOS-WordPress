#!/bin/bash
# whitelist.sh - whitelists trusted IPs

# Cloudflare IP ranges
csf -a 204.93.240.0/24 Cloudflare
csf -a 204.93.177.0/24 Cloudflare
csf -a 199.27.128.0/21 Cloudflare
csf -a 173.245.48.0/20 Cloudflare
csf -a 103.21.244.0/22 Cloudflare
csf -a 103.22.200.0/22 Cloudflare
csf -a 103.31.4.0/22 Cloudflare
csf -a 141.101.64.0/18 Cloudflare
csf -a 108.162.192.0/18 Cloudflare
csf -a 190.93.240.0/20 Cloudflare
csf -a 188.114.96.0/20 Cloudflare
csf -a 197.234.240.0/22 Cloudflare
csf -a 198.41.128.0/17 Cloudflare
csf -a 162.158.0.0/15 Cloudflare
