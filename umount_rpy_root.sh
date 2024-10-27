#!/usr/bin/bash

set -euo pipefail

# Get target dir from argv[1], use script dir if not present
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TGT_DIR=${1:-"$SCRIPT_DIR"}
MNT_PATH="$TGT_DIR/mnt"

sudo umount "$MNT_PATH"

