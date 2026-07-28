#!/bin/bash

set -e

if [ $# -lt 2 ] ;then
    echo "Usage: <filename> <dstfolder>"
    exit 1
fi

SRC_FILE="$1"
DST_FOLDER="$2"

mkdir -p $DST_FOLDER
tar --extract --gzip --no-same-owner --no-same-permissions --no-xattrs --no-acls --no-selinux --delay-directory-restore -f $SRC_FILE --strip 1 -C $DST_FOLDER
