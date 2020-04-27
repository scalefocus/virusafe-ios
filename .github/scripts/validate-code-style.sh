#!/bin/sh

files=$(git diff --name-only origin/$BASE_BRANCH_NAME origin/$BRANCH_NAME | grep -e '.*\.swift$' | sed -e 'N;s/\n/ /')

# debug
echo $files

if [ -z "$files" ]
then
	echo "No changes in *.swift files"
	exit
fi

set -o pipefail && $EXECUTABLE --strict --reporter github-actions-logging -- $files