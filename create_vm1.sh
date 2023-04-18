#!/bin/bash

export RESOURCE_GROUP_NAME=ncrcareonline
export LOCATION=eastus
export VM_NAME=ncrcarecard.com
export VM_IMAGE=ftp-image-image-20230410212242
export ADMIN_USERNAME=azureuser
export SECURITY_GROUP=ncrcareonlineSecurityGroup
export SECURITY_RULE_SSH=ncrcareonlineSecurityRuleSsh
export SECURITY_RULE_HTTP=ncrcareonlineSecurityRuleHttp
export SECURITY_RULE_HTTPS=ncrcareonlineSecurityRuleHttps
export GIT_REPO_URL=https://ncrzpr:ATBB83Xy7LBHmKbBxuNv4bzsvEN2FA48D8C4@bitbucket.org/ncrzpr/ncrcarecard.git
export FOLDER_NAME=ncrcarecard
export DOMAIN=ncrcarecard.com
export headers="Authorization: sso-key A4r4jH86KGE_9NfjFjmyiRNR48TYN8uKr5:JZCjxA1dtygHEM7iH7NQv8"

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






ssh-keygen -R $IP_ADDRESS

ssh -o "StrictHostKeyChecking no" $ADMIN_USERNAME@$IP_ADDRESS


az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo systemctl restart apache2.service"

az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo git clone $GIT_REPO_URL"

az vm run-command invoke -g $RESOURCE_GROUP_NAME -n $VM_NAME --command-id RunShellScript --scripts "sudo cp -a $FOLDER_NAME/* /var/www/html/"



curl -X PUT "https://api.godaddy.com/v1/domains/$VM_NAME/records/A/@" \
-H "accept: application/json" \
-H "Content-Type: application/json" \
-H "$headers" \
-d "[ { \"data\": \"$IP_ADDRESS\", \"port\": 1, \"priority\": 0, \"protocol\": \"string\", \"service\": \"string\", \"ttl\":600}]"