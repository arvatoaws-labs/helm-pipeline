#!/bin/bash
set -x
# ENV Params:
# CLUSTER_FILE
# OPTIONS
# COMMIT_ID Override

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
: "${COMMIT_ID:=$(git rev-parse HEAD)}"

eksctl get nodegroup --cluster $CLUSTER_NAME

OLD_COMMIT_ID=$(cut -d'v' -f 2 <<< $(eksctl get nodegroup --cluster $CLUSTER_NAME | tail -n +2 | awk '{ print $2; }' | head -n 1))
sed -i "s/-v[0-9a-f]\+$/-v$OLD_COMMIT_ID/g" $CLUSTER_FILE

NUMBER_OF_NODEGROUPS=$(yq r $CLUSTER_FILE --length nodeGroups)
for (( i=0; i<NUMBER_OF_NODEGROUPS; i++ )); do
  NEW_NAME=$(yq r $CLUSTER_FILE -j | jq ".nodeGroups[$i].name" | tr -d '"' | sed -e "s/-v[0-9a-f]\+$/-v$COMMIT_ID/g")
  yq r $CLUSTER_FILE -j | jq ".nodeGroups[$i].name = \"$NEW_NAME\"" | yq r --prettyPrint - | sed -e "s/ yes$/ \"yes\"/g" | sed -e "s/ no$/ \"no\"/g" > .tmpcopy
  mv .tmpcopy $CLUSTER_FILE
  eksctl create nodegroup -f $CLUSTER_FILE
  sleep 60
  eksctl delete nodegroup --only-missing -f $CLUSTER_FILE $OPTIONS
done

eksctl get nodegroup --cluster $CLUSTER_NAME