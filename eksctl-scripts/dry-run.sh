#!/bin/bash
set -x

if [ "$(update-or-create.sh)" == "true" ]; then
  update-cluster.sh
  update-utils.sh
  print-flux-installation.sh
else
  echo "No cluster created as of yet"
fi