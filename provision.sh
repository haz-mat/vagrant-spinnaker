#!/bin/bash
set -o verbose -o errexit -o nounset

# Deploys a localdebian installation of Spinnaker using Halyward using a Minio
# Docker container as storage backend. Opens Deck UI and Gate API externally.
# Required env vars:
# AWS_ACCOUNT_ID
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# SPINNAKER_VERSION
# BASE_URL ("http://localhost")
# DECK_PORT
# GATE_PORT

function hal_cfg {
  hal config --quiet $@
}

# Install Docker
curl -fSsL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get -yq install docker-ce

# Install Halyard
curl -fSsLO \
  https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh --user vagrant
hal --version

# Setup Minio storage backend
# These keys are set as is because of this bug:
# https://github.com/spinnaker/spinnaker/issues/2290
MINIO_ACCESS_KEY=$AWS_ACCESS_KEY_ID
MINIO_SECRET_KEY=$AWS_SECRET_ACCESS_KEY
sudo docker stop minio || true
sudo docker rm minio || true
sudo docker run \
  --name minio \
  --env "MINIO_ACCESS_KEY=$MINIO_ACCESS_KEY" \
  --env "MINIO_SECRET_KEY=$MINIO_SECRET_KEY" \
  --detach \
  --publish 9001:9000 \
  --network bridge \
  --volume /mnt/data:/data \
  --volume  /mnt/config:/root/.minio \
  minio/minio server /data || true
echo $MINIO_SECRET_KEY | hal_cfg storage s3 edit \
  --endpoint http://127.0.0.1:9001 \
  --access-key-id $MINIO_ACCESS_KEY \
  --secret-access-key
hal_cfg storage edit --type s3
mkdir -p ~/.hal/default/profiles
printf 'spinnaker.s3:\n  versioning: false' \
  > ~/.hal/default/profiles/front50-local.yml

# Configure AWS provider
echo $AWS_SECRET_ACCESS_KEY | hal_cfg provider aws edit \
  --access-key-id $AWS_ACCESS_KEY_ID \
  --secret-access-key
hal_cfg provider aws account add default \
  --account-id $AWS_ACCOUNT_ID \
  --assume-role role/spinnakerManaged || true
hal_cfg provider aws enable

# Deploy Spinnaker locally
hal_cfg version edit --version $SPINNAKER_VERSION
hal_cfg deploy edit --type localdebian
## Open Deck and Gate
hal_svc_settings_path="$HOME/.hal/default/service-settings"
mkdir -p ~/.hal/default/service-settings
echo "host: 0.0.0.0" | tee \
  $hal_svc_settings_path/gate.yml \
  $hal_svc_settings_path/deck.yml
hal_cfg security ui edit \
    --override-base-url $BASE_URL:$DECK_PORT
hal_cfg security api edit \
    --override-base-url $BASE_URL:$GATE_PORT
sudo hal --quiet deploy apply
