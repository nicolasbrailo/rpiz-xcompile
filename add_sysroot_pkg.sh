#!/usr/bin/bash

set -euo pipefail

USAGE="""
You can use a running target to get the correct packages, and the uri to the packages. Eg:

$ sudo apt list --installed | grep xkbcommon
libxkbcommon-dev/stable,now 1.5.0-1 armhf [installed]
libxkbcommon0/stable,now 1.5.0-1 armhf [installed]

$ apt-get download --print-uris libxkbcommon-dev
'http://raspbian.raspberrypi.com/raspbian/pool/main/libx/libxkbcommon/libxkbcommon-dev_1.5.0-1_armhf.deb' libxkbcommon-dev_1.5.0-1_armhf.deb 50996 SHA256:22f86a1c6c1b535d1c071885c41547cb4ec4beeddea8e9fc209a91ca80bc807b
"""

# Get target dir from argv[1], use script dir if not present
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SYSROOT_DIR=${1:-"$SCRIPT_DIR"}
PKG_CACHE="$SYSROOT_DIR/pkgs"

# Get pkg url or fail
PKG_URL="$2"
PKG_FNAME=$( basename "$PKG_URL" )

# Verify sysroot is mounted
if [ ! -d "$SYSROOT_DIR/mnt/usr/include" ] || [ ! -d "$SYSROOT_DIR/mnt/usr/lib" ] || [ ! -d "$SYSROOT_DIR/mnt/usr/share" ]; then
    echo "Can't find sysroot at $SYSROOT_DIR, try calling mount_rpy_root.sh first"
    exit 1
fi

if [ ! -e "$PKG_CACHE/$PKG_FNAME" ]; then
    echo "Will fetch $PKG_URL..."
    mkdir -p "$PKG_CACHE"
    wget --directory-prefix="$PKG_CACHE" "$PKG_URL"
fi

PKG_EXTRACT_DIR="$PKG_CACHE/${PKG_FNAME%.*}"
if [ ! -d "$PKG_EXTRACT_DIR" ]; then
    echo "Extracting $PKG_FNAME..."
    mkdir -p "$PKG_EXTRACT_DIR"
    dpkg-deb -R "$PKG_CACHE/$PKG_FNAME" "$PKG_EXTRACT_DIR"
fi

DID_SOMETHING=0
if [ -d "$PKG_EXTRACT_DIR/usr/include/" ]; then
  sudo cp -r "$PKG_EXTRACT_DIR/usr/include/"* "$SYSROOT_DIR/mnt/usr/include"
  DID_SOMETHING=1
fi
if [ -d "$PKG_EXTRACT_DIR/usr/lib/" ]; then
  sudo cp -r "$PKG_EXTRACT_DIR/usr/lib/"*     "$SYSROOT_DIR/mnt/usr/lib"
  DID_SOMETHING=1
fi
if [ -d "$PKG_EXTRACT_DIR/usr/share/" ]; then
  sudo cp -r "$PKG_EXTRACT_DIR/usr/share/"*   "$SYSROOT_DIR/mnt/usr/share"
  DID_SOMETHING=1
fi

if [[ "$DID_SOMETHING" -eq 1 ]]; then
  echo "[re]installed $PKG_URL to sysroot"
else
  echo "Failed to [re]install $PKG_URL to sysroot (nothing to copy?)"
  exit 1
fi
