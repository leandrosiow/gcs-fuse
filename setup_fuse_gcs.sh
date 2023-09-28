#!/usr/bin/env bash


echo "What is your GCS bucket name?"

#Read input in the assigned variable
read GCS_BUCKET_NAME


gcloud auth application-default login
# gcloud auth application-default login --no-launch-browser


## 1 Install Fuse
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update && sudo apt-get install fuse gcsfuse -y
gcsfuse -v


mkdir "$HOME/gcs-cloudshell-disk"
gcsfuse $GCS_BUCKET_NAME "$HOME/gcs-cloudshell-disk"