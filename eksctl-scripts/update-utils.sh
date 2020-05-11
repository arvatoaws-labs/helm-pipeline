#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

eksctl utils update-kube-proxy -f $CLUSTER_FILE $OPTIONS
# TODO Check Completion?
eksctl utils update-coredns -f $CLUSTER_FILE $OPTIONS
# TODO Check Completion?
eksctl utils update-aws-node -f $CLUSTER_FILE $OPTIONS
# TODO Check Completion?