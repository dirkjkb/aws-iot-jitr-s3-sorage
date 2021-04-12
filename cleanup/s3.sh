#!/bin/bash -e

BUCKET=$1

aws s3 rm s3://$BUCKET --recursive

markers=$(aws s3api list-object-versions --encoding-type url --bucket $BUCKET | jq -c '.DeleteMarkers[]')
for marker in $markers
do
    key=$(echo $marker | jq '.Key' | tr -d \")
    versionId=$(echo $marker | jq '.VersionId' | tr -d \")
    aws s3api delete-object --bucket $BUCKET --key $key --version-id $versionId
done
