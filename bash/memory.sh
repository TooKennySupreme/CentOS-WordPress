#!/bin/bash
# memory.sh - adjusts memory settings across various configuration files

# Changes shm_size to 256M - What's the optimal shm_size? Any ideas? Commits!
perl -pi -e 's/apc.shm_size=32M/apc.shm_size=256M/g' /root/centminmod/php.d/apc.ini
