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

if [ "$(yq r $CLUSTER_FILE 'addons' | grep 'vpc-cni' || echo "nope")" == "nope" ]; then
  eksctl utils update-kube-proxy -f $CLUSTER_FILE $OPTIONS
  # TODO Check Completion?
elif [ "$(eksctl get addons --name vpc-cni --cluster $CLUSTER_NAME)" ]; then
  eksctl update addon --name vpc-cni --cluster $CLUSTER_NAME
else
  eksctl create addon --name vpc-cni --cluster $CLUSTER_NAME;
fi

if [ "$(yq r $CLUSTER_FILE 'addons' | grep 'coredns' || echo "nope")" == "nope" ]; then
  eksctl utils update-coredns -f $CLUSTER_FILE $OPTIONS
  # TODO Check Completion?
elif [ "$(eksctl get addons --name coredns --cluster $CLUSTER_NAME)" ]; then
  eksctl update addon --name coredns --cluster $CLUSTER_NAME
else
  eksctl create addon --name coredns --cluster $CLUSTER_NAME;
fi

if [ "$(yq r $CLUSTER_FILE 'addons' | grep 'kube-proxy' || echo "nope")" == "nope" ]; then
  eksctl utils update-aws-node -f $CLUSTER_FILE $OPTIONS
  # TODO Check Completion?
elif [ "$(eksctl get addons --name kube-proxy --cluster $CLUSTER_NAME)" ]; then
  eksctl update addon --name kube-proxy --cluster $CLUSTER_NAME
else
  eksctl create addon --name kube-proxy --cluster $CLUSTER_NAME;
fi
