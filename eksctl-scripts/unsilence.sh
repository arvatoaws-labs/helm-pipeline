#!/bin/bash

curl -v -X DELETE -u $ALERTMANAGER_USER:$ALERTMANAGER_PW "https://alertmanager-basic.prod.mgmt.aws-arvato.com/api/v2/silence/$(cat silence_id)" -H "accept: application/json"

aws route53 list-health-checks | jq '.HealthChecks[] | "\(.Id) \(.HealthCheckConfig.FullyQualifiedDomainName)"' | grep traefik | tr -d '"' | awk '{ print $1; }' | xargs -i aws route53 update-health-check --health-check-id {} --no-disabled