#!/bin/bash

DEFAULT_MINIO_URL=http://`netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'`:9000
PACKER_FOLDER=/root/$BUCKET/$BUILDFOLDER
# If the Minio URL is not set, default to the parent IP on port 9000
MINIO_HOST_URL=${MINIO_URL:-$DEFAULT_MINIO_URL}

mc config host add minio $MINIO_HOST_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY 
mc cp minio/$BUCKET/$BUILDFOLDER/ /root --recursive
