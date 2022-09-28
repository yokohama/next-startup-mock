#!/bin/sh

if [ "${TARGET_ENV}" = "" ]; then
  echo '[Error]'
  echo '- TARGET_ENV param required. [ local | dev | prod ]'
  echo '- ex) TARGET_ENV=local ./init/ecr_init_push.sh local'
  exit 1
fi

AWS_ENV_FILE=openapi/aws_apigateway_env.conf

ENV_TITLE=`cat ${AWS_ENV_FILE} | grep ${TARGET_ENV}_title | awk -F'[=]' '{print $2}'`
ENV_DESC=`cat ${AWS_ENV_FILE} | grep ${TARGET_ENV}_desc | awk -F'[=]' '{print $2}'`

if [ "${ENV_TITLE}" = "" ] || [ "${ENV_DESC}" = "" ]; then
  echo '[Error]'
  echo "${TARGET_ENV}_title and ${TARGET_NAME}_desc were required in ${AWS_ENV_FILE}"
  exit 1
fi

SOURCE_YAML_FILE='./openapi/root.yaml'
OUT_YAML_FILE='./openapi/out.yaml'

VPC_LINK_ID=''
json=$(aws apigateway get-vpc-links | jq -c -r '.items')
len=$(echo $json | jq length)
for i in $( seq 0 $(($len - 1)) ); do
  vpc_link=$(echo $json | jq -r .[$i].name)
  if [ "${vpc_link}" = "Link-${TARGET_ENV}" ]; then
    VPC_LINK_ID=$(echo $json | jq -r .[$i].id)
  fi
done

if [ "${VPC_LINK_ID}" = "" ]; then
  echo '[Error]'
  echo "vpc link Link-${TARGET_ENV} is not found."
  exit 1
fi

LB_URI=`aws elbv2 describe-load-balancers --name Nlb-${TARGET_ENV} --query "LoadBalancers[0].DNSName" | jq -r '.'`
if [ "${LB_URI}" = "null" ] || [ "${LB_URI}" = "" ]; then
  echo '[Error]'
  echo "URI Nbl-${TARGET_ENV} is not found."
  exit 1
fi

# 元のyamlファイルのenvをAPIGateway用に上書き
sed -r "s/(^\s{2})#\s(title:\s)(.*$)/\1\2${ENV_TITLE}/" ${SOURCE_YAML_FILE} |
  sed -r "s/(^\s{2})#\s(description:\s)(.*$)/\1\2${ENV_DESC}/" |
  sed -r "s/\{NEXT-STARTUP-VPC-LINK-ID\}/${VPC_LINK_ID}/" |
  sed -r "s/\{NEXT-STARTUP-LB-URI\}/${LB_URI}/" > ${OUT_YAML_FILE}

API_GATEWAY_ID=''
json=$(aws apigateway get-rest-apis | jq -c -r '.items')
len=$(echo $json | jq length)
for i in $( seq 0 $(($len - 1)) ); do
  gateway=$(echo $json | jq -r .[$i].name)
  if [ "${gateway}" = "Api-${TARGET_ENV}" ]; then
    API_GATEWAY_ID=$(echo $json | jq -r .[$i].id)
  fi
done

if [ "${API_GATEWAY_ID}" = "" ]; then
  echo '[Error]'
  echo "APIGateway Api-${TARGET_ENV} is not found."
  exit 1
fi

aws apigateway put-rest-api \
  --mode overwrite \
  --cli-binary-format raw-in-base64-out \
  --rest-api-id ${API_GATEWAY_ID} \
  --body "file://${OUT_YAML_FILE}"

rm -rf ${OUT_YAML_FILE}
