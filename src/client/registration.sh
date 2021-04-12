#!/bin/bash -e

COMMON_NAME=$1
ENDPOINT_ADDRESS=$2
CERTIFICATE_COUNTRY_CODE=$3

## set File Directory
CURRENT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $CURRENT_DIRECTORY
mkdir -p certificate
cd certificate

#Create Device Certificate
openssl genrsa -out deviceCert.key 2048
openssl req -new -key deviceCert.key -out deviceCert.csr \
    -subj "/C=$CERTIFICATE_COUNTRY_CODE/ST=./O=./L=./CN=$COMMON_NAME/OU=./emailAddress=./"
openssl x509 -req -in deviceCert.csr -CA deviceRootCA.pem -CAkey deviceRootCA.key -CAcreateserial -days 365 -sha256 \
    -out deviceCert.crt
cat deviceCert.crt deviceRootCA.pem > deviceCertAndCACert.crt

#Download Amazon Certificate
wget -O AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem

# Initialize first connection which fails
mosquitto_pub --cafile AmazonRootCA1.pem --cert deviceCertAndCACert.crt --key deviceCert.key -h $ENDPOINT_ADDRESS -p 8883 -q 1 -t  foo/bar -i  anyclientID --tls-version tlsv1.2 -m "Hello" -d || true

