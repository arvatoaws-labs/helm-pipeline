#!/bin/bash

set -e

if [ $# -lt 2 ] ;then
    echo "Usage: <filename> <dstfolder>"
    exit 1
fi

SRC_FILE="$1"
DST_FOLDER="$2"

mkdir -p $DST_FOLDER

# GitHub tarballs do not require preserving ownership, ACL/xattr, or SELinux labels.
# Disabling those metadata restores avoids extraction failures on some CodeBuild
# filesystems (e.g. "Function not implemented" from tar while creating files).
tar \
  --extract \
  --gzip \
  --verbose \
  --file "$SRC_FILE" \
  --strip-components=1 \
  --directory "$DST_FOLDER" \
  --no-same-owner \
  --no-same-permissions \
  --delay-directory-restore \
  --no-xattrs \
  --no-acls \
  --no-selinux
