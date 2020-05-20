#!/bin/bash
CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
START_DATE=$(date --utc +%FT%T.%3NZ)
END_DATE=$(date --utc +%FT%T.%3NZ -d "+2 hours")

curl -X POST "https://alertmanager-basic.prod.mgmt.aws-arvato.com/api/v2/silences" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{\"comment\":\"Automatic silence by eksctl update pipeline\", \"createdBy\":\"eksctl_pipeline\", \"endsAt\":\"$END_DATE\", \"startsAt\": \"$START_DATE\", \"matchers\": [{\"isRegex\": false, \"name\": \"cluster\", \"value\": \"$CLUSTER_NAME\"}]}" | jq '.silenceID' | tr -d '"' > silence_id

