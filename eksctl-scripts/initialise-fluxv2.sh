#!/bin/bash

# TODO: Howto upgrade?
flux bootstrap github --owner=$GIT_OWNER --repository=$GIT_REPO --branch=$GIT_BRANCH --path=$BOOTSTRAP_DIR --version $FLUX_VERSION