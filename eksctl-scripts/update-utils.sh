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

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq eval '.metadata.name' -)

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
  eksctl update addon -f $CLUSTER_FILE --force || eksctl create addon -f $CLUSTER_FILE --force
fi
