#!/bin/bash

if [ "$(update-or-create.sh)" == "true" ]; then
  #popeye -l error -o junit > popeye-tests.xml
  popeye -l error -o junit --save --output-file popeye-tests.xml
else
  echo '<?xml version="1.0" encoding="UTF-8"?><testsuites name="Popeye" tests="0" failures="0" errors="0"></testsuites>' > popeye-tests.xml
fi

exit 0