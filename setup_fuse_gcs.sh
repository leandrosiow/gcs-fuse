#!/usr/bin/env bash

# This terminate the script if a command that fails
set -e


echo "What is your GCS bucket name?"

# Read input (GCS bucket name) and assigned it to a variable
read GCS_BUCKET_NAME

if [[ -z "$GCS_BUCKET_NAME" ]]
then
      GCS_BUCKET_NAME=gcs-clouddisk
      echo "Setting disk to default bucket name $GCS_BUCKET_NAME"
fi


# Setup gcs-fuse repo
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`

## Update install wget 
sudo apt update && sudo apt install wget

# As apt-key is deprecated we will use the following method to add gpg or asc keys
# 1. Create a directory to store keys
KEYRING_DIR=/etc/apt/keyrings
sudo mkdir -p $KEYRING_DIR
echo "deb [signed-by=$KEYRING_DIR/apt-key.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
sudo wget -P $KEYRING_DIR https://packages.cloud.google.com/apt/doc/apt-key.gpg


## 1 Install Fuse
sudo apt-get install fuse gcsfuse -y
gcsfuse -v


# Perform a gcloud login in order to mount the GCS bucket 
gcloud auth login --no-launch-browser
# gcloud auth application-default login --no-launch-browser


mkdir "$HOME/gcs-clouddisk"
gcsfuse $GCS_BUCKET_NAME "$HOME/gcs-clouddisk"
cd $HOME/gcs-clouddisk
pwd