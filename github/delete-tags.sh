#!/usr/bin/env bash

# @kristijorgji
# This script will delete all git tags matching the provided regex
# Example:
# bash github/delete-tags.sh ".+@kristijorgji.+"


 ghToken="${GH_TOKEN}"
 listPath=git-refs-list.json
 owner=kristijorgji
 repo=winstonjs-utils
 pattern=$1

 curl \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$owner/$repo/git/refs/tags \
    | jq -r "
        .[] | select( .ref | test(\"$pattern\"))
    " > $listPath


# delete all refs exported above
for ref in $(jq -r '.ref' $listPath); do
    echo -e "now deleting ref $ref\n"
    curl \
    -u $owner:$ghToken \
    -X DELETE \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$owner/$repo/git/$ref
done

rm $listPath