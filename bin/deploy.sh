#!/bin/sh

if [ "$TARGET_ENV" == "dev" ]; then
  TARGET_ENV=dev
elif [ "$TARGET_ENV" == "prod" ]; then
  TARGET_ENV=prod
else
  TARGET_ENV=local
fi

AWS_ENV_FILE=openapi/aws_apigateway_env.conf

ENV_TITLE=`cat ${AWS_ENV_FILE} | grep ${TARGET_ENV}_title | awk -F'[=]' '{print $2}'`
ENV_DESC=`cat ${AWS_ENV_FILE} | grep ${TARGET_ENV}_desc | awk -F'[=]' '{print $2}'`

SOURCE_YAML_FILE='./openapi/root.yaml'
YAML_FILE='./openapi/out.yaml'

# 元のyamlファイルのenvをAPIGateway用に上書き
sed -r "s/(^\s{2})#\s(title:\s)(.*$)/\1\2${ENV_TITLE}/" ${SOURCE_YAML_FILE} |
  sed -r "s/(^\s{2})#\s(description:\s)(.*$)/\1\2${ENV_DESC}/" > ${YAML_FILE}

ITEMS=`aws apigateway get-rest-apis`

for item in $(echo $ITEMS | jq -c '.items[]'); do
  TARGET_NAME=`echo $item | jq -r '.name'`
  if [ "Api-${TARGET_ENV}" == "$TARGET_NAME" ]; then
    API_GATEWAY_ID=`echo $item | jq -r '.id'`
  fi
done

aws apigateway put-rest-api \
  --mode overwrite \
  --cli-binary-format raw-in-base64-out \
  --rest-api-id ${API_GATEWAY_ID} \
  --body "file://${YAML_FILE}"

rm -rf ${YAML_FILE}
