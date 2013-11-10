#!/bin/bash
# Changes shm_size to 256M - What's the optimal shm_size? Any ideas? Commits!
perl -pi -e 's/apc.shm_size=32M/apc.shm_size=256M/g' /root/centminmod/php.d/apc.ini
# Disable APC CLI from apc.ini
perl -pi -e 's/apc.enable_cli=1/apc.enable_cli=0/g' /root/centminmod/php.d/apc.ini
# Disables APC CLI from php.ini - not sure if this is necessary but the general consensus on the internet seems to be that it should be disabled. It also causes problems with WP-CLI should you decide to use that.
echo "apc.enable_cli = Off" >> /usr/local/lib/php.ini
