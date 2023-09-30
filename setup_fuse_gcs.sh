#!/usr/bin/env bash

# This terminate the script if a command that fails
set -e


echo "What is your GCS bucket name?"

# Read input (GCS bucket name) and assigned it to a variable
read GCS_BUCKET_NAME

if [[ -z "$GCS_BUCKET_NAME" ]]
then
      echo "Setting disk to default bucket name $GCS_BUCKET_NAME"
      GCS_BUCKET_NAME=gcs-clouddisk
else
     
fi


gcloud auth login
# gcloud auth application-default login --no-launch-browser


## 1 Install Fuse
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg -O --output-dir /etc/apt/trusted.gpg.d/
sudo apt-get update && sudo apt-get install fuse gcsfuse -y
gcsfuse -v


mkdir "$HOME/gcs-clouddisk"
gcsfuse $GCS_BUCKET_NAME "$HOME/gcs-clouddisk"
cd $HOME/gcs-clouddisk
pwd