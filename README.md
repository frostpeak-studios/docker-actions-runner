# Docker Actions Runner

A containerized GitHub Actions runner for running GitHub Actions workflows in Docker containers. This is useful for deploying multiple runners on a single machine and ensuring workflows run in a clean environment.

## Usage

### Prerequisites

- Docker
- Docker Compose
- GitHub Personal Access Token (with `Organization/Self-hosted runners:read and write` scope)

### Setup

1. Copy the `docker-compose.yml` file to your server.
2. Fill out the environment variables in the `runner.env.example` and rename it to `runner.env`.
3. Run `docker-compose up -d` to start the runner.

### Configuration

By default, 4 runners are launched and are given the following resources:

- 25-35% of the CPU
- 128-300MB of memory

You can adjust these values by modifying the `docker-compose.yml` file to fit your needs.

If your workflows require any additional packages or dependencies, fork this repo and modify the `Dockerfile` to include them in the section with the comment `# NOTE: If your workflows require additional dependencies, add them here.`.

### Teardown

1. Run `docker-compose down` to stop the runner. This will auto-remove the runner from the GitHub organization.
2. If runners remain in the GitHub organization marked as `offline`, run `utils/prune-runners.sh` to remove them.

## Credits

This project is based on the work of [Alessandro Baccini](https://github.com/beikeni/github-runner-dockerfile) and [Michael Herman](https://testdriven.io/blog/github-actions-docker/), with modifications made to suit our use case.
