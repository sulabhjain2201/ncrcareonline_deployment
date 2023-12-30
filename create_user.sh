#!/bin/bash

set -x #echo on


export displayName=$1

export userPrincipalName=$2

groupName="varrion_developer"

generatedPassword=$(openssl rand -base64 12)



userId=$(az ad user create \
  --display-name "$displayName" \
  --user-principal-name "$userPrincipalName" \
  --password "$generatedPassword" \
  --force-change-password-next-login true \
  --query objectId \
  --output tsv)

echo "User created successfully with User ID: $userId and auto-generated password: $generatedPassword"

az ad group member add --group "$groupName" --member-id $userId




