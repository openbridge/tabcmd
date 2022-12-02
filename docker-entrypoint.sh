#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o xtrace

#bash -c 'tabcmd --accepteula'

exec "$@"
