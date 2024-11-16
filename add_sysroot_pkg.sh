#!/usr/bin/bash

set -euo pipefail

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

sudo cp -r "$PKG_EXTRACT_DIR/usr/include/" "$SYSROOT_DIR/mnt/usr/include"
sudo cp -r "$PKG_EXTRACT_DIR/usr/lib/"     "$SYSROOT_DIR/mnt/usr/lib"
sudo cp -r "$PKG_EXTRACT_DIR/usr/share/"   "$SYSROOT_DIR/mnt/usr/share"

echo "[re]installed $PKG_URL to sysroot"
