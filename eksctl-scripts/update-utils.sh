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

eksctl utils update-kube-proxy -f $CLUSTER_FILE $OPTIONS
# TODO Check Completion?
eksctl utils update-coredns -f $CLUSTER_FILE $OPTIONS
# TODO Check Completion?
eksctl utils update-aws-node -f $CLUSTER_FILE $OPTIONS
# TODO Check Completion?

kubectl -n kube-system get cm kube-proxy-config -o yaml | sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/' | kubectl apply -f -