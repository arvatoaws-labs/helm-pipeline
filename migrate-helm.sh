#!/bin/bash

if [ $#  -ne 2 ]; then
  echo "Invalid params"
  echo "Usage: $0 RELEASE NAMESPACE"
  exit 1
else
  RELEASE=$1
  NAMESPACE=$2
fi

HELM_STATUS="$(helm status $RELEASE)"
if [ $? -eq 0 ]; then
  echo "helm2 is still used"
else
  echo "helm2 is not used anymore"
  exit 0
fi

echo "converting config helm2 to helm3"
helm 2to3 move config

HELM_STATUS="$(helm3 status $RELEASE -n $NAMESPACE)"
if [ $? -eq 0 ]; then
  echo "helm3 is used"
  exit 0
else
  echo "helm3 is not used yet"
fi

echo "converting release helm2 to helm3"
helm 2to3 convert $RELEASE
