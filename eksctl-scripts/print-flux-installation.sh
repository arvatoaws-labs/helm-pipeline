#!/bin/bash

if [ "$FLUXv2" == "true" ]; then
  flux install --version $FLUX_VERSION --export | kubectl apply --dry-run=client -f-
else
  helm3 repo add fluxcd https://charts.fluxcd.io
  helm3 repo update

  echo "Current state of flux:"
  helm3 ls -n fluxcd
  echo "Desired versions:"
  if [ "$FLUX_VERSION" == "latest" ]; then
    helm3 search repo fluxcd/flux
  else
    echo "Flux: $FLUX_VERSION"
  fi
  if [ "$HELM_OPERATOR_VERSION" == "latest" ]; then
    helm3 search repo fluxcd/helm-operator
  else
    echo "Helm Operator: $HELM_OPERATOR_VERSION"
  fi
fi
