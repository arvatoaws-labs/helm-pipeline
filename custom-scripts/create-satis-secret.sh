#!/bin/bash

# SATIS_AUTH_FILE
if [ -z ${SATIS_AUTH_FILE+x} ]; then
    echo missing env SATIS_AUTH_FILE
    exit 1
fi

# SATIS_USERNAME
if [ -z ${SATIS_USERNAME+x} ]; then
    echo missing env SATIS_USERNAME
    exit 1
fi

# SATIS_PASSWORD
if [ -z ${SATIS_PASSWORD+x} ]; then
    echo missing env SATIS_PASSWORD
    exit 1
fi

# SATIS_REPOSITORY
if [ -z ${SATIS_REPOSITORY+x} ]; then
    echo missing env SATIS_REPOSITORY
    exit 1
fi

cat <<EOF > $SATIS_AUTH_FILE
{
    "http-basic": {
        "$SATIS_REPOSITORY": {
            "username": "$SATIS_USERNAME",
            "password": "$SATIS_PASSWORD"
        }
    }
}
EOF