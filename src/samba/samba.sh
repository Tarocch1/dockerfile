#!/usr/bin/env bash

set -Eeuo pipefail

smbd -i &
nmbd -i &

wait -n

exit $?
