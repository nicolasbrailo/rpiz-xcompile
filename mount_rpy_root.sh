#!/usr/bin/bash

set -euo pipefail

IMG_URL=https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf.img.xz

IMG_FNAME=$(basename "$IMG_URL" .xz)

# If img doesn't exist, fetch it and uncompress it
if [ ! -e "$IMG_FNAME" ]; then
  if [ ! -e "$IMG_FNAME.xz" ]; then
    echo "Fetching image..."
    wget "$IMG_URL"
  fi
  echo "Uncompressing image..."
	xz -d "$IMG_FNAME.xz"
fi

# Mount image, if not mounted already
IMG_FULLPATH=$(pwd)/"$IMG_FNAME"
if [[ $( mount | grep -c "$IMG_FULLPATH" ) -eq 0 ]]; then
  # Find the offset for the root partition and mount
  offset=$( sudo fdisk -lu "$IMG_FNAME" | grep Linux | awk '{print $2}' )
  offset=$((512 * offset))
  mkdir -p mnt
  sudo mount -o loop,offset=$offset "$IMG_FNAME" ./mnt
fi


