#!/bin/bash
set -x

if [ "$(update-or-create.sh)" == "true" ]; then
  backup.sh
  update-cluster.sh
  update-utils.sh
  update-nodegroups.sh
  update-utils.sh
else
  create-cluster.sh
  create-fargate-profile.sh
fi

initialise-flux.sh