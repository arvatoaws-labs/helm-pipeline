#!/bin/bash

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: eks-console-dashboard-read-access-clusterrole
rules:
- apiGroups:
  - ""
  resources:
  - nodes
  - namespaces
  - pods
  verbs:
  - get
  - list
- apiGroups:
  - apps
  resources:
  - deployments
  - daemonsets
  - statefulsets
  - replicasets
  verbs:
  - get
  - list
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: eks-console-dashboard-read-access-binding
subjects:
- kind: Group
  name: eks-console-dashboard-read-access-group
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: eks-console-dashboard-read-access-clusterrole
  apiGroup: rbac.authorization.k8s.io
EOF