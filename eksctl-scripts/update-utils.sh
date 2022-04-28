#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

if [ -z ${CLUSTER_FILE+x} ];
then
    echo "missing ENV CLUSTER_FILE"
    exit 1
fi

if ! [ -f $CLUSTER_FILE ];
then
    echo "cannot read file $CLUSTER_FILE"
    exit 1
fi

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
ACTIVATED_ADD_ONS=$(eksctl get addon --cluster $CLUSTER_NAME --output json | jq '.[].Name' )

echo "This are the activated managed add-ons in cluster: " $ACTIVATED_ADD_ONS

if [ "$(yq eval '.addons' $CLUSTER_FILE | grep 'vpc-cni' || echo "nope")" == "nope" ]; then
  eksctl utils update-kube-proxy -f $CLUSTER_FILE $OPTIONS
  # TODO Check Completion?
else
  export DO_MANAGED_UPDATE="true"
fi
if [ "$(yq eval '.addons' $CLUSTER_FILE | grep 'coredns' || echo "nope")" == "nope" ]; then
  eksctl utils update-coredns -f $CLUSTER_FILE $OPTIONS
  # TODO Check Completion?
else
  export DO_MANAGED_UPDATE="true"
fi
if [ "$(yq eval '.addons' $CLUSTER_FILE | grep 'kube-proxy' || echo "nope")" == "nope" ]; then
  eksctl utils update-aws-node -f $CLUSTER_FILE $OPTIONS
  # TODO Check Completion?
else
  export DO_MANAGED_UPDATE="true"
fi

if [ -v OPTIONS ] && [ "$DO_MANAGED_UPDATE" == "true" ]; then
  for a in $(yq eval '.addons[].name' $CLUSTER_FILE) # check add-ons in cluster file
  do
    if [ $(echo $ACTIVATED_ADD_ONS | grep -w $a) ]; then # if add-on from cluster file is activated in cluster already, then it will be updated
      eksctl update addon --name $a --cluster $CLUSTER_NAME
    else
      echo "Addon" $a "not found. It will be created!" && eksctl create addon --name $a --cluster $CLUSTER_NAME # else it would be created
    fi
  done
fi
