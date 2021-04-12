# AWS IOT Just-in-Time-Registration (JITR) example
This project is a dummy project to implement an AWS Iot Case witch contains:
- All Incoming client messages 
  are [automatically saved in S3](https://aws.amazon.com/blogs/iot/bites-of-iot-creating-aws-iot-rules-with-aws-cloudformation)
  with specific time stamp.
- A client can automatically register it self
  via [just in time registration](https://aws.amazon.com/blogs/iot/just-in-time-registration-of-device-certificates-on-aws-iot).

## Certificate Creation
For simplicity this project only works with root and device certificates and no intermediate certificates. In production, the
intermediate CA certificate would be signed by the root CA that then signs the device certificates. In that case, you
register the intermediate CA certificate with AWS IoT. The Certificate creation process in this project followes the steps explained
in the AWS Blog [How do I set up JITP with AWS IoT Core?](https://aws.amazon.com/premiumsupport/knowledge-center/aws-iot-core-jitp-setup/).

## Pre Requests
To run all scripts you need the following tools installed
- [jq](https://linuxhint.com/bash_jq_command/)
- [mosquitto_pub](https://www.mankier.com/1/mosquitto_pub)

## Create & Update
Before running the [deploy script](./deploy.sh) you have to Replace `<ACCOUNT_ID>` value with your AWS account ID in the [jitp_template](./src/root_ca/jitp_template.json). Replace also eu-central-1 with the AWS Region that you're using.


To create or update the stack you just call the [deploy script](./deploy.sh):
```bash
./deploy.sh <CLOUDFORMATION_STACK_NAME> <SAM_DEPLOYMENT_BUCKET> <CERTIFICATE_COUNTRY_CODE_CODE> <THING_NAME>
```

### Variables:
- `CLOUDFORMATION_STACK_NAME`: The Name of the CloudFormation stack.
- `SAM_DEPLOYMENT_BUCKET`:  The Name of the S3 bucket where the CloudFormation template.
- `CERTIFICATE_COUNTRY_CODE_CODE`: The [two letter Country code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) where the certificate originates.
- `THING_NAME`: The Name of AWS IOT Thing that will be created.

## Delete
To delete the CloudFormation stack you call the [delete script](./delete.sh):

```bash
./delete.sh <CLOUDFORMATION_STACK_NAME> <S3_HOSTING_BUCKET>
```

### Variables:
- `CLOUDFORMATION_STACK_NAME`: The Name of the CloudFormation stack.
- `S3_HOSTING_BUCKET`: The Name of the bucket through witch the static website is hosted.
