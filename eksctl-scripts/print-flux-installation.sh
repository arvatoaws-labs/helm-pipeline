#!/bin/bash

helm repo add fluxcd https://charts.fluxcd.io
helm repo update

echo "Current state of flux:"
helm ls -n fluxcd
echo "Desired versions:"
if [ "$FLUX_VERSION" == "latest" ]; then
  helm search repo fluxcd/flux
else
  echo "Flux: $FLUX_VERSION"
fi
if [ "$HELM_OPERATOR_VERSION" == "latest" ]; then
  helm search repo fluxcd/helm-operator
else
  echo "Helm Operator: $HELM_OPERATOR_VERSION"
fi