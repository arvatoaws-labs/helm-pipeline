#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

echo "eksctl version:"
eksctl version --output json

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
ENVIR_FILE=$(echo $CLUSTER_FILE | rev | cut -d '/' -f 1 | rev)
ENVIR=$(echo $ENVIR_FILE | cut -d '.' -f 1)

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/$(cat base-templates/cert-manager/release.yaml | yq r - spec.chart.version)/cert-manager.crds.yaml

# TODO: disable or enable service monitors

helm repo add fluxcd https://charts.fluxcd.io
helm repo update
kubectl create namespace fluxcd
helm upgrade -i flux -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux # TODO: allow fixed version
sleep 10
helm upgrade -i helm-operator -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator # TODO: allow fixed version
sleep 60
if [ "$(update-or-create.sh)" == "false" ]; then
  # TODO get repo name? Doesn't work yet
  gh api -X POST repos/arvatoaws/flux-repo-mgmt/keys -F "{\"title\":\"flux-$ENVIR\",\"key\":\"$(fluxctl identity --k8s-fwd-ns fluxcd)\",\"read_only\":false}"
fi