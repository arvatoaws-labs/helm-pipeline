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
elif [ $(eksctl get addons --cluster $CLUSTER_NAME --name vpc-cni) ]; then
  eksctl update addon -f $CLUSTER_FILE --name vpc-cni
  else
    eksctl create addon -f $CLUSTER_FILE;
fi

if [ "$(yq r $CLUSTER_FILE 'addons' | grep 'coredns' || echo "nope")" == "nope" ]; then
  eksctl utils update-coredns -f $CLUSTER_FILE $OPTIONS
  # TODO Check Completion?
elif [ $(eksctl get addons --cluster $CLUSTER_NAME --name coredns) ]; then
  eksctl update addon -f $CLUSTER_FILE --name coredns
  else
    eksctl create addon -f $CLUSTER_FILE --name coredns;
fi

if [ "$(yq r $CLUSTER_FILE 'addons' | grep 'kube-proxy' || echo "nope")" == "nope" ]; then
  eksctl utils update-aws-node -f $CLUSTER_FILE $OPTIONS
  # TODO Check Completion?
elif [ $(eksctl get addons --cluster $CLUSTER_NAME --name kube-proxy) ]; then
  eksctl update addon -f $CLUSTER_FILE --name kube-proxy
  else
    eksctl create addon -f $CLUSTER_FILE --name kube-proxy;
fi
