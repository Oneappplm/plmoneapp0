#!/bin/bash
set -e
rm -f /plmhealthone-app/tmp/pids/server.pid
exec "$@"