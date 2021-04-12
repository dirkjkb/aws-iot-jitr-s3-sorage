#!/bin/bash -e

CLOUDFORMATION_STACK_NAME=$1
S3_HOSTING_BUCKET=$2

./cleanup/iot.sh 
./cleanup/s3.sh $S3_HOSTING_BUCKET

aws cloudformation delete-stack --stack-name $CLOUDFORMATION_STACK_NAME

echo "Deletion successful!"