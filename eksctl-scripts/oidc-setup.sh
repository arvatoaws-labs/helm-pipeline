#!/bin/bash

if [[ "$(cat $CLUSTER_FILE | yq r - iam.withOIDC)" == "true" ]]; then
  eksctl utils associate-iam-oidc-provider -f $CLUSTER_FILE | grep "already associated"
  if [[ $? -eq 1 ]]; then
    eksctl utils associate-iam-oidc-provider -f $CLUSTER_FILE --approve
  fi
  eksctl create iamserviceaccount -f $CLUSTER_FILE --approve --override-existing-serviceaccounts
  eksctl update iamserviceaccount -f $CLUSTER_FILE --approve
  eksctl delete iamserviceaccount -f $CLUSTER_FILE --approve --only-missing
else
  echo "OIDC not requested"
fi
