#!/bin/bash -e

CLOUDFORMATION_STACK_NAME=$1
SAM_DEPLOYMENT_BUCKET=$2
CERTIFICATE_COUNTRY_CODE_CODE=$3
THING_NAME=$4

sam deploy --capabilities CAPABILITY_NAMED_IAM CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --stack-name $CLOUDFORMATION_STACK_NAME \
    --s3-bucket $SAM_DEPLOYMENT_BUCKET \
    --template template.yaml \
    --no-fail-on-empty-changeset

ENDPOINT_ADDRESS=$(aws iot describe-endpoint --endpoint-type iot:Data-ATS | jq '.endpointAddress' | tr -d \")

## Create Certificates
./src/root_ca/create.sh $CERTIFICATE_COUNTRY_CODE_CODE
./src/client/registration.sh $THING_NAME $ENDPOINT_ADDRESS $CERTIFICATE_COUNTRY_CODE_CODE

# Run Python Client
cd ./src/client
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python client.py --thing_name $THING_NAME --endpoint $ENDPOINT_ADDRESS