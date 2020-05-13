#!/bin/bash
set -x
# ENV Params:
# CLUSTER_FILE
# OPTIONS
# COMMIT_ID Override

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
: "${COMMIT_ID:=$(git rev-parse HEAD)}"
sed -i "s/-v[0-9a-f]\+$/-v$COMMIT_ID/g" $CLUSTER_FILE
# TODO: Is this sensible?
# git add $CLUSTER_FILE
# git commit -m "Pipeline Node Upgrade"
# git push
eksctl get nodegroup --cluster $CLUSTER_NAME
eksctl create nodegroup -f $CLUSTER_FILE
eksctl delete nodegroup --only-missing -f $CLUSTER_FILE $OPTIONS
