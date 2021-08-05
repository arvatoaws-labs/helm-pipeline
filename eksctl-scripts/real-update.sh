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

kubectl -n kube-system get cm kube-proxy-config -o yaml | sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/' | kubectl apply -f -

oidc-setup.sh
setup-aws-access.sh

if [ "$UPDATE_FLUX" == "false" ]; then
  echo "Skipping Flux upgrade / initialization"
else
  if [ "$FLUXv2" == "true" ]; then
    initialise-fluxv2.sh
  else
    initialise-flux.sh
  fi
fi
