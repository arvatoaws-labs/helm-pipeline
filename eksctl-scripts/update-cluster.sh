#!/bin/bash
# ENV Params:
# CLUSTER_FILE
# OPTIONS

eksctl update cluster -f $CLUSTER_FILE $OPTIONS