#!/bin/bash

curl -v -X DELETE "https://alertmanager-basic.prod.mgmt.aws-arvato.com/api/v2/silences/$(cat silence_id)" -H "accept: application/json"