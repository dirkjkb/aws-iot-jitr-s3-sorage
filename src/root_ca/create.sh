#!/bin/bash -e

CERTIFICATE_COUNTRY_CODE=$3

# set File Directory
CURRENT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $CURRENT_DIRECTORY
mkdir -p certificate
cd certificate

# Generate Root Certificate
openssl genrsa -out deviceRootCA.key 2048
openssl req -x509 -new -nodes -key deviceRootCA.key -sha256 -days 1024 \
    -subj "/C=$CERTIFICATE_COUNTRY_CODE/ST=./O=./L=./CN=./OU=./emailAddress=./" \
    -out deviceRootCA.pem

# Generate Verification Certificate
registrationCode=$(aws iot get-registration-code | jq '.registrationCode' | tr -d \")
openssl genrsa -out verificationCert.key 2048
openssl req -new -key verificationCert.key \
    -subj "/C=$CERTIFICATE_COUNTRY_CODE/ST=./O=./L=./CN=$registrationCode/OU=./emailAddress=./" \
    -out verificationCert.csr

openssl x509 -req -in verificationCert.csr -CA deviceRootCA.pem -CAkey deviceRootCA.key -CAcreateserial -days 500 -sha256 -out verificationCert.csr

# Register the Root Certificate
aws iot register-ca-certificate --ca-certificate file://deviceRootCA.pem \
    --verification-cert file://verificationCert.csr \
    --set-as-active \
    --allow-auto-registration \
    --registration-config file://../jitp_template.json \

# Copy Certificate to use it in the client
mkdir -p ../../client/certificate/
cp deviceRootCA.pem ../../client/certificate/
cp deviceRootCA.key ../../client/certificate/