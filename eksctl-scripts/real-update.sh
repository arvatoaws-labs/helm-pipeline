#!/bin/bash
set -x

if ! [ -f $CLUSTER_FILE ];
then
    echo "cannot read file $CLUSTER_FILE"
    exit 1
fi

export IS_UPDATE=$(update-or-create.sh)

if [ "$IS_UPDATE" == "true" ]; then
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
    if [ "$IS_UPDATE" == "true" ]; then
      initialise-fluxv2.sh
    else
      if [ "$(yq r $CLUSTER_FILE 'gitops' | grep 'flux' || echo "no_gitops")" == "no_gitops" ]; then
        initialise-fluxv2.sh
      fi
    fi
  else
    initialise-flux.sh
  fi
fi