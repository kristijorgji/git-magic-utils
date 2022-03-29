#!/usr/bin/env bash

# @kristijorgji
# This script will delete all packages which names match pattern versions except last versions.
# Example:
# bash github/delete-packages.sh ".+@html.+"

if [ $# -eq 0 ]
  then
    echo "No package name pattern supplied"
    exit -1
fi

ghToken="${GH_TOKEN}"
owner=kristijorgji
pattern=$1
package_type=npm

r=$(curl -s \
    -u $owner:$ghToken \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/users/$owner/packages?package_type=${package_type} \
    | jq -r ".[] | select( .name | test(\"$pattern\")) | .name")
packages=(`echo ${r}`); # split by space and store in array

# get versions of found packages then delete all versions aside last one
for package in "${packages[@]}"; do
    echo -e "Checking package $package"

    versions=$(curl -s \
    -u $owner:$ghToken \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/users/$owner/packages/${package_type}/$package/versions \
    | jq -r ".[] | .id")
    versions=(`echo ${versions}`); # split by space and store in array
    unset versions[0]; # remove first version(most recent) so we don't delete it

    for version in "${versions[@]}"; do
        echo -e "Deleting version $version";
        curl -s \
        -u $owner:$ghToken \
        -X DELETE \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/users/$owner/packages/${package_type}/$package/versions/${version}
    done
    echo -e "Finished with package $package\n\n"
done
