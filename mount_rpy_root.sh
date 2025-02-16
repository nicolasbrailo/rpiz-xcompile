#!/usr/bin/bash

set -euo pipefail

IMG_URL=https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2024-11-19/2024-11-19-raspios-bookworm-armhf.img.xz

# Get target dir from argv[1], use script dir if not present
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TGT_DIR=${1:-"$SCRIPT_DIR"}

IMG_FNAME=$(basename "$IMG_URL" .xz)
IMG_PATH="$TGT_DIR/$IMG_FNAME"
MNT_PATH="$TGT_DIR/mnt"

# If img doesn't exist, fetch it and uncompress it
if [ ! -e "$IMG_PATH" ]; then
  if [ ! -e "$IMG_PATH.xz" ]; then
    echo "Fetching image..."
    wget --directory-prefix="$TGT_DIR" "$IMG_URL"
  fi
  echo "Uncompressing image..."

  pushd "$TGT_DIR"
	xz -d "$IMG_FNAME.xz"
  popd
fi

# Mount image, if not mounted already
if [[ $( mount | grep -c "$IMG_PATH" ) -eq 0 ]]; then
  # Find the offset for the root partition and mount
  offset=$( sudo fdisk -lu "$IMG_PATH" | grep Linux | awk '{print $2}' )
  offset=$((512 * offset))
  mkdir -p "$MNT_PATH"
  sudo mount -o loop,offset=$offset "$IMG_PATH" "$MNT_PATH"
fi


