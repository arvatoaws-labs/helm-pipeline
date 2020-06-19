#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

echo "eksctl version:"
eksctl version --output json

eksctl create cluster -f $CLUSTER_FILE