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

if [ "$(update-or-create.sh)" == "true" ] && [ $(helm ls -n fluxcd | grep flux- | grep deployed | wc -l) -gt 0 ] && [ $(helm ls -n fluxcd | grep helm-operator | grep deployed | wc -l) -gt 0 ] && [ "$(helm get values -n fluxcd flux | yq r - prometheus.serviceMonitor.create)" == "true" ] && [ "$(helm get values -n fluxcd helm-operator | yq r - prometheus.serviceMonitor.create)" == "true" ] && [ $(helm get values -n fluxcd flux | yq r - additionalArgs --length) -gt 1 ] ; then
  echo "Service Monitors and Fluxcloud already integrated into flux"
  HELM_TOBE_REDONE="false"
else
  yq w -i flux-helm-values/$ENVIR_FILE prometheus.serviceMonitor.enabled false
  yq w -i flux-helm-values/helm_operator.yaml prometheus.serviceMonitor.create false
  yq r flux-helm-values/$ENVIR_FILE -j | jq '.additionalArgs = ["--manifest-generation=true"]' | yq r --prettyPrint - > .tmpcopy
  mv .tmpcopy flux-helm-values/$ENVIR_FILE
  HELM_TOBE_REDONE="true"
fi

helm repo add fluxcd https://charts.fluxcd.io
helm repo update
kubectl create namespace fluxcd
if [ "$FLUX_VERSION" == "latest" ]; then
  helm upgrade -i flux -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux
else
  helm upgrade -i flux --version $FLUX_VERSION -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux
fi
sleep 10
if [ "$HELM_OPERATOR_VERSION" == "latest" ]; then
  helm upgrade -i helm-operator -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator
else
  helm upgrade -i helm-operator --version $HELM_OPERATOR_VERSION -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator
fi
sleep 60
if [ "$(update-or-create.sh)" == "false" ]; then
  gh api -X POST repos/arvatoaws/$GIT_REPO/keys -F title="flux-$ENVIR" -F key="$(fluxctl identity --k8s-fwd-ns fluxcd)" -F read_only=false
fi

if [ "$HELM_TOBE_REDONE" == "true" ]; then
  yq w -i flux-helm-values/$ENVIR_FILE prometheus.serviceMonitor.enabled true
  yq w -i flux-helm-values/helm_operator.yaml prometheus.serviceMonitor.create true
  yq r flux-helm-values/$ENVIR_FILE -j | jq '.additionalArgs = ["--manifest-generation=true","--connect=ws://fluxcloud"]' | yq r --prettyPrint - > .tmpcopy
  mv .tmpcopy flux-helm-values/$ENVIR_FILE
  let j=0
  until [ $(kubectl get po -n fluxcd | grep Running | grep fluxcloud | wc -l) -gt 0 ]
  do
    echo "fluxcloud not available yet"
    sleep 20
    ((j=j+1))
    if [ $j -gt 20 ]; then
      echo "fluxcloud failed to show up"
      exit 1
    fi
  done
  let i=0
  until kubectl get crd servicemonitors.monitoring.coreos.com
  do
    echo "Service Monitors not available yet"
    sleep 20
    ((i=i+1))
    if [ $i -gt 20 ]; then
      echo "prometheus service monitors failed to show up"
      exit 1
    fi
  done
  if [ "$FLUX_VERSION" == "latest" ]; then
    helm upgrade -i flux -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux
  else
    helm upgrade -i flux --version $FLUX_VERSION -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux
  fi
  sleep 10
  if [ "$HELM_OPERATOR_VERSION" == "latest" ]; then
    helm upgrade -i helm-operator -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator
  else
    helm upgrade -i helm-operator --version $HELM_OPERATOR_VERSION -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator
  fi
fi