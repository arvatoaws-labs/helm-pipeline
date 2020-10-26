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
oidc-setup.sh
setup-aws-access.sh

if [ "$UPDATE_FLUX" == "false" ]; then
  echo "Skipping Flux upgrade / initialization"
else
  initialise-flux.sh
fi