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
export SSL_REQUIRED=$3

az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VM_NAME \
  --image $VM_IMAGE \
  --nsg $SECURITY_GROUP \
  --size Standard_B1s \
  --admin-username $ADMIN_USERNAME \
  --ssh-key-values public_key.pub \
  --public-ip-sku Standard


export IP_ADDRESS=$(az vm show --show-details --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --query publicIps --output tsv)

az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "rm -rf /var/www/html/*"

az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo chmod 777 /var/www/html"

az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo chmod 777 /etc/apache2/ssl"

rm -rf $FOLDER_NAME

git clone $GIT_REPO_URL


ssh-keygen -R $IP_ADDRESS

ssh -o "StrictHostKeyChecking accept-new" $ADMIN_USERNAME@$IP_ADDRESS

scp -r -i ncrvcr_key.pem $FOLDER_NAME/*  azureuser@$IP_ADDRESS:/var/www/html

scp -r -i ncrvcr_key.pem apache2.conf  azureuser@$IP_ADDRESS:/etc/apache2/ssl

az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo cp /etc/apache2/ssl/apache2.conf /etc/apache2"

if [ $SSL_REQUIRED = 'true' ]
then
  echo 'Started SSL processing'
  cp 000-default.conf $DOMAIN
  sed -i '' "s/domainname/$DOMAIN/" $DOMAIN/000-default.conf
  scp -r -i ncrvcr_key.pem $DOMAIN/*  azureuser@$IP_ADDRESS:/etc/apache2/ssl
  az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo chmod 777 /etc/apache2/sites-enabled"
  az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo cp /etc/apache2/ssl/000-default.conf /etc/apache2/sites-enabled"
fi

az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo a2enmod rewrite"

az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo systemctl restart apache2.service"



curl -X PUT "https://api.godaddy.com/v1/domains/$VM_NAME/records/A/@" \
-H "accept: application/json" \
-H "Content-Type: application/json" \
-H "$headers" \
-d "[ { \"data\": \"$IP_ADDRESS\", \"port\": 1, \"priority\": 0, \"protocol\": \"string\", \"service\": \"string\", \"ttl\":600}]"