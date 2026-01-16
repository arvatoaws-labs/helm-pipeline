#!/bin/bash

# Fetch all tags
git fetch --tags

# Get the latest tag (assumes tags are in 'vX.Y' format)
latest_tag=$(git tag -l --sort -version:refname | head -n 1)

# If there are no tags yet, start with v0.1
if [ -z "$latest_tag" ]; then
  echo "0.1"
  exit 0
fi

# Split the version into major and minor numbers
version_bits=(${latest_tag//./ })

major=${version_bits[0]}
minor=${version_bits[1]}

# Remove 'v' prefix
major=${major#v}

# Increment the minor version
let minor++

# Output the new version
echo "${major}.${minor}"