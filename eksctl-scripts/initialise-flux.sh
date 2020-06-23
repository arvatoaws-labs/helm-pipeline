#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

echo "eksctl version:"
eksctl version --output json

echo "Cluster File: $CLUSTER_FILE"
ACCOUNT=$(aws sts get-caller-identity | jq '.Account' | tr -d '"')
echo "Account: $ACCOUNT"
CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
echo "Cluster Name: $CLUSTER_NAME"
ENVIR_FILE=$(echo $CLUSTER_FILE | rev | cut -d '/' -f 1 | rev)
echo "Envir File: $ENVIR_FILE"
ENVIR=$(echo $ENVIR_FILE | cut -d '.' -f 1)
echo "Envir: $ENVIR"

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/$(cat base-templates/cert-manager/release.yaml | yq r - spec.chart.version)/cert-manager.crds.yaml

kubectl get configmaps -n kube-system aws-auth -o yaml > .tmpcurrentaws-auth
yq d -i .tmpcurrentaws-auth metadata.creationTimestamp
yq d -i .tmpcurrentaws-auth metadata.resourceVersion
yq d -i .tmpcurrentaws-auth metadata.selfLink
yq d -i .tmpcurrentaws-auth metadata.uid
NEW_CONTENT=$(cat .tmpcurrentaws-auth | yq r - data.mapRoles | yq r - -j | jq 'map({ (.rolearn): . }) | add' | jq ".\"arn:aws:iam::${ACCOUNT}:role/ToolsAcctCodePipelineKubernetesRole\" = {\"groups\":[\"system:masters\"],\"username\":\"codebuild\",\"rolearn\":\"arn:aws:iam::${ACCOUNT}:role/ToolsAcctCodePipelineKubernetesRole\"}" | jq ".\"arn:aws:iam::${ACCOUNT}:role/CsAdministratorRole\" = {\"groups\":[\"system:masters\"],\"username\":\"asyadmin\",\"rolearn\":\"arn:aws:iam::${ACCOUNT}:role/CsAdministratorRole\"}" | jq 'to_entries | map_values(.value)' | yq r - --prettyPrint)
yq w -i -- .tmpcurrentaws-auth data.mapRoles "$NEW_CONTENT"
echo "New aws-auth map:"
cat .tmpcurrentaws-auth
kubectl apply -f .tmpcurrentaws-auth
rm .tmpcurrentaws-auth

if [ $(helm3 ls -n fluxcd | grep flux- | grep deployed | wc -l) -gt 0 ] && [ $(helm3 ls -n fluxcd | grep helm-operator | grep deployed | wc -l) -gt 0 ] && [ "$(helm3 get values -n fluxcd flux | yq r - prometheus.serviceMonitor.create)" == "true" ] && [ "$(helm3 get values -n fluxcd helm-operator | yq r - prometheus.serviceMonitor.create)" == "true" ] && [ $(helm3 get values -n fluxcd flux | yq r - additionalArgs --length) -gt 1 ] ; then
  echo "Service Monitors and Fluxcloud already integrated into flux"
  HELM_TOBE_REDONE="false"
else
  echo "Installing without service monitors and fluxcloud first"
  yq w -i flux-helm-values/$ENVIR_FILE prometheus.serviceMonitor.create false
  yq w -i flux-helm-values/helm_operator.yaml prometheus.serviceMonitor.create false
  yq r flux-helm-values/$ENVIR_FILE -j | jq '.additionalArgs = ["--manifest-generation=true"]' | yq r --prettyPrint - > .tmpcopy
  mv .tmpcopy flux-helm-values/$ENVIR_FILE
  HELM_TOBE_REDONE="true"
fi

helm3 repo add fluxcd https://charts.fluxcd.io
helm3 repo update
kubectl create namespace fluxcd
if [ "$FLUX_VERSION" == "latest" ]; then
  helm3 upgrade -i flux -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux
else
  helm3 upgrade -i flux --version $FLUX_VERSION -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux
fi
sleep 10
if [ "$HELM_OPERATOR_VERSION" == "latest" ]; then
  helm3 upgrade -i helm-operator -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator
else
  helm3 upgrade -i helm-operator --version $HELM_OPERATOR_VERSION -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator
fi
sleep 60
KEY=$(fluxctl identity --k8s-fwd-ns fluxcd)
if [ $(gh api repos/arvatoaws/$GIT_REPO/keys | jq ". as \$f | \"$KEY\" | IN(\$f[].key)") == "false" ]; then
  gh api -X POST repos/arvatoaws/$GIT_REPO/keys -F title="flux-$ENVIR" -F key="$KEY" -F read_only=false
fi

if [ "$HELM_TOBE_REDONE" == "true" ]; then
  echo "Fixing flux by readding service monitors and fluxcloud"
  yq w -i flux-helm-values/$ENVIR_FILE prometheus.serviceMonitor.create true
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
    helm3 upgrade -i flux -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux
  else
    helm3 upgrade -i flux --version $FLUX_VERSION -f flux-helm-values/$ENVIR_FILE --namespace fluxcd fluxcd/flux
  fi
  sleep 10
  if [ "$HELM_OPERATOR_VERSION" == "latest" ]; then
    helm3 upgrade -i helm-operator -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator
  else
    helm3 upgrade -i helm-operator --version $HELM_OPERATOR_VERSION -f flux-helm-values/helm_operator.yaml --namespace fluxcd fluxcd/helm-operator
  fi
fi