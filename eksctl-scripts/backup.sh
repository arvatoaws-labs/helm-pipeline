#!/bin/bash

# Backup
if [ $(velero version | grep "error getting server version" | wc -l) -lt 1 ]; then
  echo "Performing pre upgrade backup"
  velero backup create "prepipelineupgrade-$(date +%F-%H-%M-%S)" --wait
fi