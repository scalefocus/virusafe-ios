#!/bin/sh

files=$(git diff --name-only origin/$BASE_BRANCH_NAME origin/$BRANCH_NAME | grep -e '.*\.swift$' | sed -e 'N;s/\n/ /')

if [ -z "$files" ]
then
	echo "No changes in *.swift files"
	exit
fi

if [ ! -x "${EXECUTABLE}" ]; then
    echo "SwiftLint was not found"
	exit 2
fi

$EXECUTABLE --strict --config '.swiftlint.yml' --reporter github-actions-logging -- $files