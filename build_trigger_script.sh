#!/usr/bin/env bash
# fail if any commands fails
set -e
# make pipelines' return status equal the last command to exit with a non-zero status, or zero if all commands exit successfully
set -o pipefail
# debug log
set -x
TRIGGER_PATHS="macos"
TRIGGER_PATHS_ANDROID="android"
echo "Trigger Paths: $TRIGGER_PATHS"

if [ -z "$BITRISEIO_GIT_BRANCH_DEST" ]
then
    echo "No PR detected. Skipping selective builds."
    exit 0
fi

git fetch origin "$BITRISEIO_GIT_BRANCH_DEST" --depth 1

DIFF_FILES="$(git diff --name-only origin/${BITRISEIO_GIT_BRANCH_DEST})"

set +x
PATH_PATTERN=$TRIGGER_PATHS

echo "PATH_PATTERN: $PATH_PATTERN"
set -x

check_app_diff ()
{
    set +e
    echo $DIFF_FILES | grep -E $1
    exit_status=$?
    if [[ $exit_status = 1 ]]; then
      echo "No changes detected. Aborting build."
    else
      echo "Changes detected. Running build."
      curl https://app.bitrise.io/app/eca9a000-663f-4392-8800-aef0fca2dc14/build/start.json -L --data '{"build_params":{"branch":"master"},"hook_info":{"build_trigger_token":"$BUILD_TOKEN","type":"bitrise"},"triggered_by":"curl"}'
    fi
    set -e
}

check_app_diff_android ()
{
    set +e
    echo $DIFF_FILES | grep -E $1
    exit_status=$?
    if [[ $exit_status = 1 ]]; then
      echo "No changes detected. Aborting build."
    else
      echo "Changes detected. Running build."
      curl https://app.bitrise.io/app/eca9a000-663f-4392-8800-aef0fca2dc14/build/start.json -L --data '{"build_params":{"branch":"master"},"hook_info":{"build_trigger_token":"$BUILD_TOKEN","type":"bitrise"},"triggered_by":"curl"}'
    fi
    set -e
}

check_app_diff "$PATH_PATTERN"
check_app_diff "$TRIGGER_PATHS_ANDROID"

exit 0
