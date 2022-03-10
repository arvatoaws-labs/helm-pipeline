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

if [ "$(yq eval '.metadata.version' $CLUSTER_FILE )" == "auto" ]; then
  MAX_SUPPORTED_VERSION=$(eksctl version -o json | jq '.EKSServerSupportedVersions | map(tonumber) | max')
  echo "Setting autoversion to $MAX_SUPPORTED_VERSION for creation"
  sed -i "s/version:\ auto/version:\ \"$MAX_SUPPORTED_VERSION\"/g" $CLUSTER_FILE
  VERSION_OVERWRITEN="true"
fi

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq eval '.metadata.name' -)
CURRENT_VERSION=$(eksctl get cluster -o json -n $CLUSTER_NAME | jq ".[].Version")

echo "Current Cluster Version: $CURRENT_VERSION"
eksctl upgrade cluster -f $CLUSTER_FILE $OPTIONS

if [ "$VERSION_OVERWRITEN" == "true" ]; then
  sed -i "s/version:\ \"$MAX_SUPPORTED_VERSION\"/version:\ auto/g" $CLUSTER_FILE
fi
