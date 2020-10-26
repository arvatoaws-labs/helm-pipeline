#!/bin/bash

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
START_DATE=$(date --utc +%FT%T.%3NZ)
END_DATE=$(date --utc +%FT%T.%3NZ -d "+2 hours")

curl -X POST -u $ALERTMANAGER_USER:$ALERTMANAGER_PW "https://alertmanager-basic.prod.mgmt.aws-arvato.com/api/v2/silences" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{\"comment\":\"Automatic silence by eksctl update pipeline\", \"createdBy\":\"eksctl_pipeline\", \"endsAt\":\"$END_DATE\", \"startsAt\": \"$START_DATE\", \"matchers\": [{\"isRegex\": false, \"name\": \"cluster\", \"value\": \"$CLUSTER_NAME\"}]}" | jq '.silenceID' | tr -d '"' > silence_id

aws route53 list-health-checks | jq '.HealthChecks[] | "\(.Id) \(.HealthCheckConfig.FullyQualifiedDomainName)"' | grep traefik | tr -d '"' | awk '{ print $1; }' | xargs -i aws route53 update-health-check --health-check-id {} --disabled