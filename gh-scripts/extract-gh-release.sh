#!/bin/bash

set -euo pipefail

if [ $# -lt 2 ] ;then
    echo "Usage: <filename> <dstfolder>"
    exit 1
fi

SRC_FILE="$1"
DST_FOLDER="$2"

mkdir -p "$DST_FOLDER"

# Use bsdtar instead of GNU tar. Fedora 44+ GNU tar relies on openat2, which is
# blocked by seccomp in some CI runtimes (e.g. AWS CodeBuild) and fails with
# "Function not implemented" when extracting into subdirectories.
bsdtar -xvzf "$SRC_FILE" -C "$DST_FOLDER" --strip-components 1
