#!/bin/sh

ENV=dev
REGION=ap-south-1
# PASSWORD=`pwgen -s 16 1`
PASSWORD="postgres01"
echo "Database connection password is ${PASSWORD}"
# exit 0

HOST_NAME=$1
if [ -z "$HOST_NAME" ]
then
    echo "Please provide host_name"
    exit 1
fi

S3_PATH_GIT_KEY_ENCRYPTED=$2
if [ -z "$S3_PATH_GIT_KEY_ENCRYPTED" ]
then
    echo "Please provide encrypted git private key s3 location."
    exit 1
fi

S3_PATH_SECRETS_ENCRYPTED=$3
if [ -z "$S3_PATH_SECRETS_ENCRYPTED" ]
then
    echo "Please provide encrypted .env file s3 location."
    exit 1
fi

kms_key=$4
if [ -z "$kms_key" ]
then
    echo "Please provide aws kms key for decrypting the files."
    exit 1
fi

ADMIN_EMAIL=$5
if [ -z "$ADMIN_EMAIL" ]
then
    echo "Please provide admin user email."
    exit 1
fi

ADMIN_PHONE=$6
if [ -z "$ADMIN_PHONE" ]
then
    echo "Please provide admin user phone."
    exit 1
fi

ADMIN_PASS=$7
if [ -z "$ADMIN_PASS" ]
then
    echo "Please provide admin user login password."
    exit 1
fi

# copy secrets file from aws s3
if [[ -f "git_key.encrypted"  ]]; then
    rm -f git_key.encrypted id_rsa
fi

aws s3 cp $S3_PATH_GIT_KEY_ENCRYPTED ./git_key.encrypted

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "aws cp failed 1"
    exit 1
fi

# decrypt the file
aws kms decrypt --ciphertext-blob fileb://git_key.encrypted --key-id $kms_key --output text --query Plaintext | base64 --decode > id_rsa

if [[ -f "secrets.encrypted" ]]; then
    rm -f secrets.encrypted .env
fi

aws s3 cp $S3_PATH_SECRETS_ENCRYPTED ./secrets.encrypted

retVal=$?
if [ $retVal -ne 0 ]; then
    echo "aws cp failed 2"
    exit 1
fi

# decrypt the file
aws kms decrypt --ciphertext-blob fileb://secrets.encrypted --key-id $kms_key --output text --query Plaintext | base64 --decode > .env


# deploy cloud formation stack to create postgres db
cd stacks

aws cloudformation create-stack --stack-name qms-${ENV}-rds-resource --template-body file://create-resources.yml --parameters ParameterKey=Environment,ParameterValue=${ENV} ParameterKey=Rgn,ParameterValue=${REGION} ParameterKey=RootPass,ParameterValue=${PASSWORD}

########### wait for stack to complete ########
aws cloudformation describe-stacks --stack-name qms-${ENV}-rds-resource > output.json
cat output.json | grep 'StackStatus' | awk -F ":" '{print $2}' | awk -F '"' '{print $2}' > out.txt

STACK_STATUS=`cat out.txt`

rm -f out.txt

echo "stack status: $STACK_STATUS"

while [ "$STACK_STATUS" != "CREATE_COMPLETE" ]
do
	echo "Create RDS instance in progress. Waitng for 2 minutes ....."
    sleep 2m
    aws cloudformation describe-stacks --stack-name qms-${ENV}-rds-resource > output.json
	cat output.json | grep 'StackStatus' | awk -F ":" '{print $2}' | awk -F '"' '{print $2}' > out.txt

	STACK_STATUS=`cat out.txt`

	rm -f out.txt
	echo "stack status: $STACK_STATUS"
done

cd ..
###############

# get postgres db host and port
aws cloudformation describe-stacks --stack-name qms-${ENV}-rds-resource > stack_output.json

cat stack_output.json | grep 'OutputValue' | awk -F ":" '{print $2}' | awk -F '"' '{print $2}' > out.txt

DB_HOST=`cat out.txt`

# delete stack if no db host found
if [ -z "$DB_HOST" ]
then
    echo "Db host details not found. Deleting stack ...."
    aws cloudformation delete-stack qms-${ENV}-rds-resource
    exit 1
fi

# update .env file
sed -i "s|HOST_NAME|$HOST_NAME|g" .env
sed -i "s|^DB_PASS=.*|DB_PASS= $PASSWORD|" .env

sed -i "s|^DB_HOST=.*|DB_HOST= $DB_HOST|" .env
sed -i "s|^DB_USER=.*|DB_USER= root|" .env

sed -i "s|^ADMIN_EMAIL=.*|ADMIN_EMAIL= $ADMIN_EMAIL|" .env
sed -i "s|^ADMIN_PASS=.*|ADMIN_PASS= $ADMIN_PASS|" .env
sed -i "s|^ADMIN_PHONE=.*|ADMIN_PHONE= $ADMIN_PHONE|" .env

api_url="$HOST_NAME:5050"
# build the docker image
docker build -t panasonicqms .

# run docker  container
docker run -e APP_NAME=qms_node -e DB_HOST=${DB_HOST} -e DB_USER=root -e DB_PASSWORD=${PASSWORD} -e DB_NAME=neuro_qms -p 5000:5000 -p 5050:5050 -p 44959:44959 -d panasonicqms

docker run -e APP_NAME=kiosk -e DB_HOST=${DB_HOST} -e DB_USER=root -e DB_PASSWORD=${PASSWORD} -e DB_NAME=neuro_qms -p 44956:44956 -d panasonicqms

docker run -e APP_NAME=pwa -e API_URL=${api_url} -e DB_HOST=${DB_HOST} -e DB_USER=root -e DB_PASSWORD=${PASSWORD} -e DB_NAME=neuro_qms -p 8081:8081 -d panasonicqms


