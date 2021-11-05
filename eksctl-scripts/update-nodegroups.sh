#!/bin/bash
set -x
# ENV Params:
# CLUSTER_FILE
# OPTIONS
# COMMIT_ID Override

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

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
: "${COMMIT_ID:=$(git rev-parse HEAD)}"
: "${WAIT_TIME:=60}"

eksctl get nodegroup --cluster $CLUSTER_NAME

# Managed Nodegroups
if [ "$(yq r $CLUSTER_FILE 'managedNodeGroups' | grep 'name' || echo "nope")" == "nope" ]; then
  echo "No managed nodegroups found"
else
  # TODO: Config changes upgrade is only partially supported, as far as I understand it
  # unchanged fields for nodegroup managed-group-a: the following fields remain unchanged; they are not supported by `eksctl update nodegroup`: AvailabilityZones, ScalingConfig, VolumeSize, SSH, PrivateNetworking, Tags, IAM, VolumeType, VolumeEncrypted, InstanceTypes, Spot, Taints
  eksctl update nodegroup -f $CLUSTER_FILE
  yq r $CLUSTER_FILE 'managedNodeGroups' | grep name | awk '{ print $3; }' | xargs -i eksctl upgrade nodegroup --cluster=$CLUSTER_NAME --name={}
fi

if [ "$(yq r $CLUSTER_FILE 'managedNodeGroups' | grep 'name' || echo "nope")" == "nope" ]; then
  echo "No managed nodegroups found"
else
  OLD_COMMIT_ID=$(cut -d'v' -f 2 <<< $(eksctl get nodegroup --cluster $CLUSTER_NAME | grep $CLUSTER_NAME | awk '{ print $2; }' | head -n 1))
  sed -i "s/-v[0-9a-f]\+$/-v$OLD_COMMIT_ID/g" $CLUSTER_FILE

  NUMBER_OF_NODEGROUPS=$(yq r $CLUSTER_FILE --length nodeGroups)
  for (( i=0; i<NUMBER_OF_NODEGROUPS; i++ )); do
    NEW_NAME=$(yq r $CLUSTER_FILE -j | jq ".nodeGroups[$i].name" | tr -d '"' | sed -e "s/-v[0-9a-f]\+$/-v$COMMIT_ID/g")
    yq r $CLUSTER_FILE -j | jq ".nodeGroups[$i].name = \"$NEW_NAME\"" | yq r --prettyPrint - | sed -e "s/ yes$/ \"yes\"/g" | sed -e "s/ no$/ \"no\"/g" > .tmpcopy
    mv .tmpcopy $CLUSTER_FILE
    eksctl create nodegroup -f $CLUSTER_FILE --skip-outdated-addons-check=true
    sleep $WAIT_TIME
    eksctl delete nodegroup --only-missing -f $CLUSTER_FILE $OPTIONS
  done
fi