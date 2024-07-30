#!/bin/bash

#
### WARNING: This script will delete all offline runners in the organization. Use with caution.
#
# This script is meant to prune zombie runners that have been left in the organization. This is usually due
# to containers being stopped without properly cleaning up the runner, typically because the container was
# stopped with a SIGKILL signal, which doesn't provide time for the cleanup function to run.

ORG=$1
TOKEN=$2

# Get the list of all runners in the org and filter out the offline runners.
# See: https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#list-self-hosted-runners-for-an-organization
RUNNER_LIST=$(curl -L \
                -H "Accept: application/vnd.github+json" \
                -H "Authorization: Bearer ${TOKEN}" \
                -H "X-GitHub-Api-Version: 2022-11-28" \
                https://api.github.com/orgs/"${ORG}"/actions/runners |
                jq '[.runners[] | select(.status | contains("offline")) | {id: .id}]')

# Loop through the list of offline runners and delete them.
for id in $(echo "$RUNNER_LIST" | jq -r '.[] | @base64'); do
  _jq() {
    echo "${id}" | base64 --decode | jq -r "${1}"
  }

  _jq '.id'

  # Delete the runner.
  # See: https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#delete-a-self-hosted-runner-from-an-organization
  curl -L \
    -X DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${TOKEN}" \
    https://api.github.com/orgs/"${ORG}"/actions/runners/"$(_jq '.id')"

done
