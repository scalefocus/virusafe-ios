#!/bin/sh

local_branch=$BRANCH_NAME

valid_branch_regex="^(feature|feat|bugfix|hotfix|release)(\/[a-z0-9._-]+){1,2}$"

if [[ ! $local_branch =~ $valid_branch_regex ]]
then
    echo "Branch name '$local_branch' doesn't adhere to this contract: $valid_branch_regex."
    exit 1
fi

exit