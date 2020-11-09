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