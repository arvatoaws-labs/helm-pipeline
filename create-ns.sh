#!/bin/bash

if [ $#  -ne 1 ]; then
  echo "Invalid params"
  echo "Usage: $0 NAMESPACE"
  exit 1
else
  NAMESPACE=$1
fi

HELM_STATUS="$(kubectl get ns $NAMESPACE)"
if [ $? -eq 0 ]; then
  echo "ns is already there"
  exit 0
else
  kubectl create ns $NAMESPACE
fi