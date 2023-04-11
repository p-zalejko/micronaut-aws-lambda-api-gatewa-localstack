#!/bin/sh
#
# this script comes from https://gist.github.com/crypticmind/c75db15fd774fe8f53282c3ccbe3d7ad
#
# A few adjustments were made, added API configuration for GET and POST methods
#
API_NAME=example0000
REGION=us-east-1
STAGE=test

function fail() {
    echo $2
    exit $1
}

awslocal lambda create-function \
    --region ${REGION} \
    --function-name ${API_NAME} \
    --runtime provided.al2 \
    --handler com.gmail.pzalejko.renovation.HomeController \
    --zip-file fileb://target/function.zip \
    --role arn:aws:iam::000000000000:role/lambda-role

[ $? == 0 ] || fail 1 "Failed: AWS / lambda / create-function"

LAMBDA_ARN=$(awslocal lambda list-functions --query "Functions[?FunctionName==\`${API_NAME}\`].FunctionArn" --output text --region ${REGION})

awslocal apigateway create-rest-api \
    --region ${REGION} \
    --name ${API_NAME}

[ $? == 0 ] || fail 2 "Failed: AWS / apigateway / create-rest-api"

API_ID=$(awslocal apigateway get-rest-apis --query "items[?name==\`${API_NAME}\`].id" --output text --region ${REGION})
PARENT_RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/`].id' --output text --region ${REGION})

awslocal apigateway create-resource \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${PARENT_RESOURCE_ID} \
    --path-part "{somethingId}"

[ $? == 0 ] || fail 3 "Failed: AWS / apigateway / create-resource"

RESOURCE_ID=$(awslocal apigateway get-resources --rest-api-id ${API_ID} --query 'items[?path==`/{somethingId}`].id' --output text --region ${REGION})

awslocal apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --request-parameters "method.request.path.somethingId=true" \
    --authorization-type "NONE" \

[ $? == 0 ] || fail 4 "Failed: AWS / apigateway / put-method GET"

awslocal apigateway put-method \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method POST \
    --request-parameters "method.request.path.somethingId=true" \
    --authorization-type "NONE" \

[ $? == 0 ] || fail 5 "Failed: AWS / apigateway / put-method POST"

awslocal apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method GET \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations \
    --passthrough-behavior WHEN_NO_MATCH \

[ $? == 0 ] || fail 6 "Failed: AWS / apigateway / put-integration GET"


awslocal apigateway put-integration \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations \
    --passthrough-behavior WHEN_NO_MATCH \

[ $? == 0 ] || fail 7 "Failed: AWS / apigateway / put-integration POST"


awslocal apigateway create-deployment \
    --region ${REGION} \
    --rest-api-id ${API_ID} \
    --stage-name ${STAGE} \

[ $? == 0 ] || fail 8 "Failed: AWS / apigateway / create-deployment"

ENDPOINT=http://localhost:4566/restapis/${API_ID}/${STAGE}/_user_request_/hello
echo "API available at: ${ENDPOINT}"
echo ""
echo ""
echo "Testing GET:"
curl -i ${ENDPOINT}?name=Pawel_GET
echo ""
echo ""
echo "Testing POST:"
curl -i -X POST -H "Content-Type:application/json" -d '{"name": "Pawel_POST"}' ${ENDPOINT}