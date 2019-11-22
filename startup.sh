#!/bin/bash

# Decode key
echo $BASE64_KEY | base64 -d - > /gcloud.json

# Auth with JSON key
if [ -n "$DEBUG" ]
then
    gcloud auth activate-service-account --key-file /gcloud.json 
else
    gcloud auth activate-service-account --key-file /gcloud.json > /dev/null 2>&1
fi
if [[ $? == 0 ]]
then
    echo "JSON auth      : Success"
else
    echo "Unable to auth"
    exit 1 
fi

# Set project
PROJECT=`cat /gcloud.json | jq -r .project_id`
if [ -n "$DEBUG" ]
then
    gcloud config set project $PROJECT
else
    gcloud config set project $PROJECT > /dev/null 2>&1
fi

if [[ $? == 0 ]]
then
    echo "Project set to : $PROJECT"
else
    echo "Unable to set project: $PROJECT"
    exit 1
fi

BACKUP_NAME=backup_`date +%Y-%m-%d`.snap

consul snapshot save -http-addr=http://$CONSUL_UI_PORT_8500_TCP_ADDR:$CONSUL_UI_PORT_8500_TCP_PORT $BACKUP_NAME
gzip $BACKUP_NAME
gsutil cp $BACKUP_NAME.gz gs://consul-staging-backup
