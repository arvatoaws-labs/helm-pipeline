#!/bin/bash

ACCOUNT=$(aws sts get-caller-identity | jq '.Account' | tr -d '"')
echo "Account: $ACCOUNT"

# Disabled as per Philipps request: kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/$(cat base-templates/cert-manager/release.yaml | yq r - spec.chart.version)/cert-manager.crds.yaml

kubectl get configmaps -n kube-system aws-auth -o yaml > .tmpcurrentaws-auth
yq -i 'del(.metadata.creationTimestamp)' .tmpcurrentaws-auth
yq -i 'del(.metadata.resourceVersion)' .tmpcurrentaws-auth
yq -i 'del(.metadata.selfLink)' .tmpcurrentaws-auth
yq -i 'del(.metadata.uid)' .tmpcurrentaws-auth
yq -i 'del(.metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"])' .tmpcurrentaws-auth
NEWCONTENT=$(cat .tmpcurrentaws-auth | yq '.data.mapRoles' - | yq -o=json - | jq 'map({ (.rolearn): . }) | add' | jq ".\"arn:aws:iam::${ACCOUNT}:role/ToolsAcctCodePipelineKubernetesRole\" = {\"groups\":[\"system:masters\"],\"username\":\"codebuild\",\"rolearn\":\"arn:aws:iam::${ACCOUNT}:role/ToolsAcctCodePipelineKubernetesRole\"}" | jq ".\"arn:aws:iam::${ACCOUNT}:role/CsAdministratorRole\" = {\"groups\":[\"system:masters\"],\"username\":\"asyadmin\",\"rolearn\":\"arn:aws:iam::${ACCOUNT}:role/CsAdministratorRole\"}" | jq ".\"arn:aws:iam::${ACCOUNT}:role/CsAuditorRole\" = {\"groups\":[\"eks-console-dashboard-read-access-group\"],\"username\":\"asysauditor\",\"rolearn\":\"arn:aws:iam::${ACCOUNT}:role/CsAuditorRole\"}" | jq 'to_entries | map_values(.value)' | yq -P -)
yq -i ".data.mapRoles = \"$NEWCONTENT\"" .tmpcurrentaws-auth
echo "New aws-auth map:"
cat .tmpcurrentaws-auth
kubectl apply -f .tmpcurrentaws-auth
rm .tmpcurrentaws-auth
