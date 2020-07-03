#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

echo "eksctl version:"
eksctl version --output json

FARGATE=$(cat $CLUSTER_FILE | yq ".fargateProfiles" | jq length)

if [ "$FARGATE" -gt 0 ]
then
    echo "found $FARGATE fargate profiles"
    eksctl create fargateprofile -f $CLUSTER_FILE
else
    echo "skipping fargate setup because no profiles found"
fi