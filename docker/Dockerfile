# Map to GitHub's ubuntu-latest image version to avoid compatibility issues with workflows.
# See: https://github.com/actions/runner-images?tab=readme-ov-file#available-images
FROM ubuntu:22.04

# See: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#labelling-container-images
LABEL org.opencontainers.image.source=https://github.com/frostpeak-studios/docker-actions-runner
LABEL org.opencontainers.image.description="A Docker image for self-hosted GitHub Actions runners."
LABEL org.opencontainers.image.licenses=MIT

# See releases: https://github.com/actions/runner/releases
ARG RUNNER_VERSION="2.318.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation.
ARG DEBIAN_FRONTEND=noninteractive

# Update packages and create a user to run the actions.
RUN apt update -y &&  \
    apt upgrade -y && \
    useradd -m docker

# Install Python and JQ dependencies.
# NOTE: If your workflows require additional dependencies, add them here.
RUN apt install -y --no-install-recommends \
    curl \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip

# Download the actions runner.
RUN cd /home/docker &&  \
    mkdir actions-runner &&  \
    cd actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# This script is included with the actions runner download.
# See the list of dependencies it installs here:
# https://github.com/actions/runner/blob/main/docs/start/envlinux.md#install-net-core-3x-linux-dependencies
RUN chown -R docker ~docker && \
    /home/docker/actions-runner/bin/installdependencies.sh

# Copy the script to configure the runner with your GitHub organization.
COPY configure-runner.sh configure-runner.sh

# Make the script executable.
RUN chmod +x configure-runner.sh

# Switch to the docker user as actions aren't allowed to run as root.
USER docker

# When the container launches, it will run the configure-runner.sh script to register with your GitHub organization.
ENTRYPOINT ["./configure-runner.sh"]
