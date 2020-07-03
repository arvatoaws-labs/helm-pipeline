#!/bin/bash

if [ $# -lt 4 ] ;then
    echo "Usage: <github token> <org/repo> <filename> <version or 'latest'>"
    exit 1
fi

TOKEN="$1"
REPO="$2"
FILE="$3"      # the name of your release asset file, e.g. build.tar.gz
VERSION=$4                       # tag name or the word "latest"
GITHUB_API_ENDPOINT="api.github.com"

alias errcho='>&2 echo'

function gh_curl() {
  curl -sL -H "Authorization: token $TOKEN" \
       -H "Accept: application/vnd.github.v3.raw" \
       $@
}

if [ "$VERSION" = "latest" ]; then
  # Github should return the latest release first.
  PARSER=".[0].tarball_url"
else
  PARSER=". | map(select(.tag_name == \"$VERSION\"))[0].tarball_url"
fi

ASSET_ID=`gh_curl https://$GITHUB_API_ENDPOINT/repos/$REPO/releases | jq -r "$PARSER"`
if [ "$ASSET_ID" = "null" ]; then
  echo "ERROR: version not found $VERSION"
  exit 1
fi

echo "Downloading file $ASSET_ID"

curl -sL --header "Authorization: token $TOKEN" $ASSET_ID > $FILE