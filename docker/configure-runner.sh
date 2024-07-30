#!/bin/bash

# This script will be run when the container starts. It configures the GitHub Actions Runner by
# registering it to the organization and then starts the runner. We need to pass a token to the script to
# authenticate with GitHub API. The token should have "Self-hosted runners" organization permissions (write).

ORG=$GH_ORG
TOKEN=$GH_TOKEN

# Fetch the token to register the runner.
# See: https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization
REG_TOKEN=$(curl -L \
              -X POST \
              -H "Accept: application/vnd.github+json" \
              -H "Authorization: Bearer ${TOKEN}" \
              -H "X-GitHub-Api-Version: 2022-11-28" \
              https://api.github.com/orgs/"${ORG}"/actions/runners/registration-token |
              jq .token --raw-output)

# Change to the runner directory.
cd /home/docker/actions-runner || exit

# Register the runner to the organization.
./config.sh --url https://github.com/"${ORG}" --token "${REG_TOKEN}"

# If the container is stopped, we need to cleanup the runner. If the container receives a SIGKILL because someone
# was impatient and smashed Ctrl+C a bunch of times, this won't be called. In that case we need to run the
# prune-runners.sh script to remove all offline (zombie) runners.
cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token "${REG_TOKEN}"
}

# We need to trap the SIGINT and SIGTERM signals to cleanup the runner before the container stops to prevent a zombie
# runner from sitting offline indefinitely in the organization.
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the runner.
./run.sh & wait $!
