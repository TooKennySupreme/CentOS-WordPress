#!/bin/bash

# Disable APC CLI in both the apc.ini file and the php.ini file.
perl -pi -e 's/apc.enable_cli=1/apc.enable_cli=0/g' /root/centminmod/php.d/apc.ini
echo "apc.enable_cli = Off" >> /usr/local/lib/php.ini
