#!/bin/bash

ACCOUNT=$(aws sts get-caller-identity | jq '.Account' | tr -d '"')
echo "Account: $ACCOUNT"

# Disabled as per Philipps request: kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/$(cat base-templates/cert-manager/release.yaml | yq r - spec.chart.version)/cert-manager.crds.yaml

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