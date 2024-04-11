#!/usr/bin/env bash
set -e

arch="$(dpkg --print-architecture)"
echo System Architecture: $arch

# Execute Vector setup script directly from curl
bash -c "$(curl -L https://setup.vector.dev)"

# Install Vector package
sudo apt-get update
sudo apt-get -y install vector