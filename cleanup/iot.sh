#!/bin/bash -e

POLICY_NAMES=$(aws iot list-policies | jq '.policies[].policyName' | tr -d \")

echo "Delete things"
#Source: https://github.com/aws-samples/aws-iot-jitp-sample-scripts/blob/master/bin/delete-thing
for thing in $(aws iot list-things | jq  '.things[].thingName' | tr -d \")
do
    echo "Delete Thing: $thing"
    certArns=$(aws iot list-thing-principals --thing-name $thing | jq -r '.["principals"][] ')
    for certArn in $certArns
    do
        certId=$(expr "$certArn" : '.*/\(.*\)')
        for policyName in $POLICY_NAMES
        do
            echo "detach Policy: $policyName from Thing: $thing"
            aws iot detach-policy --policy-name $policyName --target $certArn
        done
        aws iot update-certificate --certificate-id $certId --new-status INACTIVE
        aws iot detach-thing-principal --thing-name $thing --principal $certArn
        aws iot delete-certificate --certificate-id $certId
    done
    aws iot delete-thing --thing-name $thing
done

echo "Delete Certificates"
for certificate in $(aws iot list-certificates | jq -c '.certificates[]')
do
    certificateArn=$(echo $certificate | jq '.certificateArn' | tr -d \")
    for policyName in $POLICY_NAMES
    do
        echo "Detach Policy: $policyName from Certificate: $certificateArn"
        aws iot detach-policy --policy-name $policyName --target $certificateArn
    done

    certificateId=$(echo $certificate | jq '.certificateId' | tr -d \")
    echo "Delete Certificate: $certificateId"
    aws iot update-certificate --certificate-id $certificateId --new-status INACTIVE 
    aws iot delete-certificate --certificate-id $certificateId
done

echo "Delete CA Certificates"
for certificateId in $(aws iot list-ca-certificates | jq -c '.certificates[].certificateId' | tr -d \")
do
    echo "Delete CA-Certificate: $certificateId"
    aws iot update-ca-certificate --certificate-id $certificateId --new-status INACTIVE 
    aws iot delete-ca-certificate --certificate-id $certificateId
done

echo "Delete Policies"
for policyName in $POLICY_NAMES
do
    echo "Delete Policy: $policyName"
    aws iot delete-policy --policy-name $policyName
done
