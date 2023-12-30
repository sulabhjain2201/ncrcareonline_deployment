#!/bin/bash

set -x #echo on


export displayName=$1

export userPrincipalName=$2

export passwordProfile=$3



az ad user create \
  --display-name "$displayName" \
  --user-principal-name "$userPrincipalName" \
  --password "$passwordProfile" \
  --force-change-password-next-login true

# Output success message
echo "User created successfully."


