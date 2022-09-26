#!/bin/sh

ENV_PREFIX='NextStartUpApi-'

if [ "$TARGET_ENV" == "dev" ]; then
  TARGET_ENV=dev
elif [ "$TARGET_ENV" == "prod" ]; then
  TARGET_ENV=prod
else
  TARGET_ENV=local
fi
YAML_FILE="./openapi/root.yaml"

ITEMS=`aws apigateway get-rest-apis`

for item in $(echo $ITEMS | jq -c '.items[]'); do
  TARGET_NAME=`echo $item | jq -r '.name'`
  if [ "${ENV_PREFIX}${TARGET_ENV}" == "$TARGET_NAME" ]; then
    API_GATEWAY_ID=`echo $item | jq -r '.id'`
  fi
done

aws apigateway put-rest-api \
  --mode overwrite \
  --cli-binary-format raw-in-base64-out \
  --rest-api-id ${API_GATEWAY_ID} \
  --body "file://${YAML_FILE}"

exit 0
