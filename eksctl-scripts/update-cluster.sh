#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

echo "eksctl version:"
eksctl version --output json

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
CURRENT_VERSION=$(eksctl get cluster -o json -n $CLUSTER_NAME | jq ".[].Version")

echo "Current Cluster Version: $CURRENT_VERSION"
eksctl update cluster -f $CLUSTER_FILE $OPTIONS