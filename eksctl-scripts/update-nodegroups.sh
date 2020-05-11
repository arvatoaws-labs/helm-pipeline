#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
COMMIT_ID=$(git rev-parse HEAD)
# TODO change node group names
sed -i 's/-v[0-9a-f]\+$/-v123test/g' $CLUSTER_FILE
git add $CLUSTER_FILE
git commit -m "Pipeline Node Upgrade"
git push
eksctl get nodegroup --cluster $CLUSTER_NAME
eksctl create nodegroup -f $CLUSTER_FILE $OPTIONS
eksctl delete nodegroup --only-missing -f $CLUSTER_FILE $OPTIONS
