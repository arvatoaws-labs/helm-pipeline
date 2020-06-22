#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)

aws eks list-clusters | jq ".clusters as \$f | \"$CLUSTER_NAME\" | IN(\$f[])"