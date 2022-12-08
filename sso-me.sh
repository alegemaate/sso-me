#!/bin/bash

CREDENTIAL_NAME=${1:-default}

# Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'
WHITE='\033[0;37m'

# Title
echo -e "${YELLOW} \$\$\$\$\$\$\$\  \$\$\$\$\$\$\$\  \$\$\$\$\$\$\        \$\$\$\$\$\$\\$\$\$\$\   \$\$\$\$\$\$\  ${NC}"
echo -e "${YELLOW}\$\$  _____|\$\$  _____|\$\$  __\$\$\       \$\$  _\$\$  _\$\$\ \$\$  __\$\$\ ${NC}"
echo -e "${YELLOW}\\\$\$\$\$\$\$\  \\$\$\$\$\$\$\  \$\$ /  \$\$ |      \$\$ / \$\$ / \$\$ |\$\$\$\$\$\$\$\$ |${NC}"
echo -e "${YELLOW} \____\$\$\  \____\$\$\ \$\$ |  \$\$ |      \$\$ | \$\$ | \$\$ |\$\$   ____| ${NC}"
echo -e "${YELLOW}\$\$\$\$\$\$\$  |\$\$\$\$\$\$\$  |\\$\$\$\$\$\$  |      \$\$ | \$\$ | \$\$ |\\$\$\$\$\$\$\$\ ${NC}"
echo -e "${YELLOW}\_______/ \_______/  \______/       \__| \__| \__| \_______|${NC}\n"

# Config generator
echo -e "${WHITE}Checking config${NC}";

CONFIG_SSO_START_URL=$(aws configure get sso_start_url)
CONFIG_SSO_REGION=$(aws configure get sso_region)
CONFIG_SSO_ACCOUNT_ID=$(aws configure get sso_account_id)
CONFIG_SSO_ROLE_NAME=$(aws configure get sso_role_name)
CONFIG_REGION=$(aws configure get region)

if [ -z "$CONFIG_SSO_START_URL" ]; then
  echo -e "${RED}Oops! Your aws config file (~/.aws/config) does not contain a 'sso_start_url' property.${NC}";
  exit 0;
fi

if [ -z "$CONFIG_SSO_REGION" ]; then
  echo -e "${RED}Oops! Your aws config file (~/.aws/config) does not contain a 'sso_region' property.${NC}";
  exit 0;
fi

if [ -z "$CONFIG_SSO_ACCOUNT_ID" ]; then
  echo -e "${RED}Oops! Your aws config file (~/.aws/config) does not contain a 'sso_account_id' property.${NC}";
  exit 0;
fi

if [ -z "$CONFIG_SSO_ROLE_NAME" ]; then
  echo -e "${RED}Oops! Your aws config file (~/.aws/config) does not contain a 'sso_role_name' property.${NC}";
  exit 0;
fi

if [ -z "$CONFIG_REGION" ]; then
  echo -e "${RED}Oops! Your aws config file (~/.aws/config) does not contain a 'region' property.${NC}";
  exit 0;
fi

echo -e "${GREEN}Config looks good!${NC}\n";

# Login
echo -e "${WHITE}Logging into AWS${NC}";

aws sso login

echo -e "${GREEN}Done!${NC}\n";

echo -e "${WHITE}Reading access token${NC}";

ACCESS_TOKEN=""

for f in ~/.aws/sso/cache/*.json; 
do
  echo "Checking $f..."
  REGION=$(cat $f | jq -r '.region' )
  ACCESS_TOKEN=$(cat $f | jq -r '.accessToken')

  if [ "$ACCESS_TOKEN" ]; then
    break;
  fi
done

if [ -z "$ACCESS_TOKEN" ]; then
  echo -e "${RED}Oops! Looks like we were not able to find your cache file.${NC}";
  exit 1;
fi

echo -e "${GREEN}Done!${NC}\n";

# Creds
echo -e "${WHITE}Fetching credentials${NC}";

# Grab the temp credentials
CREDS=$(aws sso get-role-credentials --account-id $CONFIG_SSO_ACCOUNT_ID --role-name $CONFIG_SSO_ROLE_NAME --access-token $ACCESS_TOKEN)

echo -e "${GREEN}Done!${NC}\n";

echo -e "${WHITE}Writing credentials${NC}";

AWS_CREDENTIALS="[${CREDENTIAL_NAME}]\n"
AWS_CREDENTIALS+="aws_access_key_id=$(echo $CREDS | jq -r '.roleCredentials.accessKeyId')\n"
AWS_CREDENTIALS+="aws_secret_access_key=$(echo $CREDS | jq -r '.roleCredentials.secretAccessKey')\n"
AWS_CREDENTIALS+="aws_session_token=$(echo $CREDS | jq -r '.roleCredentials.sessionToken')\n"

OTHER_CREDENTIALS=$(sed -n "/${CREDENTIAL_NAME}/,/^$/ !p" ~/.aws/credentials)
OTHER_CREDENTIALS+="\n"
 
(echo -e "$AWS_CREDENTIALS" ;echo -e "$OTHER_CREDENTIALS") > ~/.aws/credentials

echo -e "${GREEN}Done!${NC}\n";

# Done
echo -e "${GREEN}You have been SSO'ed${NC}";
