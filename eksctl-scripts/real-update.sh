#!/bin/bash
set -x

if [ "$(update-or-create.sh)" == "true" ]; then
  update-cluster.sh
  update-utils.sh
  update-nodegroups.sh
  update-utils.sh
else
  create-cluster.sh
fi

initialise-flux.sh