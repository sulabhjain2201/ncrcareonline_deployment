#!/bin/bash

set -x #echo on

export RESOURCE_GROUP_NAME=ncrcareonline
export LOCATION=eastus
export VM_NAME=$1
export VM_IMAGE=ftp-image-image-20230410212242
export ADMIN_USERNAME=azureuser
export SECURITY_GROUP=ncrcareonlineSecurityGroup
export SECURITY_RULE_SSH=ncrcareonlineSecurityRuleSsh
export SECURITY_RULE_HTTP=ncrcareonlineSecurityRuleHttp
export SECURITY_RULE_HTTPS=ncrcareonlineSecurityRuleHttps
export GIT_REPO_URL=https://ncrzpr:ATBB83Xy7LBHmKbBxuNv4bzsvEN2FA48D8C4@bitbucket.org/ncrzpr/$2.git
export FOLDER_NAME=$2
export DOMAIN=$1
export headers="Authorization: sso-key A4r4jH86KGE_9NfjFjmyiRNR48TYN8uKr5:JZCjxA1dtygHEM7iH7NQv8"


rm -rf $FOLDER_NAME

git clone $GIT_REPO_URL

export IP_ADDRESS=$(az vm show --show-details --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --query publicIps --output tsv)



scp -r -i ncrvcr_key.pem $FOLDER_NAME/*  azureuser@$IP_ADDRESS:/var/www/html


az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo systemctl restart apache2.service"

