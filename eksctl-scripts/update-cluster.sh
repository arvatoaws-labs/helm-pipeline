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

echo "eksctl version:"
eksctl version --output json

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
CURRENT_VERSION=$(eksctl get cluster -o json -n $CLUSTER_NAME | jq ".[].Version")

echo "Current Cluster Version: $CURRENT_VERSION"
eksctl upgrade cluster -f $CLUSTER_FILE $OPTIONS