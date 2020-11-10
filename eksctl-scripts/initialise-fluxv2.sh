#!/bin/bash

if [ $(kubectl get ns | grep flux-system | wc -l) -gt 0 ] && [ $(kubectl get deployment -n flux-system | grep controller | wc -l) -gt 3 ]; then
  flux install --arch $ARCH --version $FLUX_VERSION
else
  flux bootstrap github --arch $ARCH --owner=$GIT_OWNER --repository=$GIT_REPO --branch=$GIT_BRANCH --path=$BOOTSTRAP_DIR --version $FLUX_VERSION
fi