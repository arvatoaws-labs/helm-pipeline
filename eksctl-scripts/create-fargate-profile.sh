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

FARGATE_JSON=$(yq eval $CLUSTER_FILE -o=json)
FARGATE_PROFILES=$(echo $FARGATE_JSON | jq ".fargateProfiles" - | jq length)

if [[ "$FARGATE_PROFILES" -gt 0 ]];
then
    echo "found fargate $FARGATE_PROFILES profiles"
    eksctl create fargateprofile -f $CLUSTER_FILE
else
    echo "skipping fargate setup because no profiles found"
fi
