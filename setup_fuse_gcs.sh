#!/usr/bin/env bash

# This terminate the script if a command that fails
set -e


# Read input (GCS bucket name) and assigned it to a variable
read -p "What is your GCS bucket name? " GCS_BUCKET_NAME

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
export KEYRING_DIR=/etc/apt/keyrings
export URL=https://packages.cloud.google.com/apt/doc/apt-key.gpg

if [[ ! -d $KEYRING_DIR ]]
then
      sudo mkdir -p $KEYRING_DIR
      sudo curl $URL | sudo tee $KEYRING_DIR/apt-key.asc > /dev/null

      echo "deb [signed-by=$KEYRING_DIR/apt-key.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
else

      printf "$KEYRING_DIR already exists"


fi

## 1 Install Fuse
sudo apt update && sudo apt-get install fuse gcsfuse -y
gcsfuse -v


# Perform a gcloud login in order to mount the GCS bucket 
gcloud auth application-default login
# gcloud auth application-default login --no-launch-browser

if [[ ! -d "$HOME/gcs-clouddisk" ]]
then
      mkdir "$HOME/gcs-clouddisk"
      gcsfuse -file-mode=777 -dir-mode=777 $GCS_BUCKET_NAME "$HOME/gcs-clouddisk"
      cd $HOME/gcs-clouddisk
      pwd
      
fi

printf "Configure GCS bucket to auto mount on reboot..."
sudo echo "gcs-clouddisk $HOME/gcs-clouddisk rw,x-systemd.requires=network-online.target,user" | sudo tee -a /etc/fstab
