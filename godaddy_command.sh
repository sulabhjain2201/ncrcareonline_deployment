#!/bin/bash
 
# This script is used to check and update your GoDaddy DNS server to the IP address of your current internet connection.
# Special thanks to mfox for his ps script
# https://github.com/markafox/GoDaddy_Powershell_DDNS
#
# First go to GoDaddy developer site to create a developer account and get your key and secret
#
# https://developer.godaddy.com/getstarted
# Be aware that there are 2 types of key and secret - one for the test server and one for the production server
# Get a key and secret for the production server
#
#Enter vaules for all variables, Latest API call requries them.
 

 
curl -X PUT "https://api.godaddy.com/v1/domains/ncrcarecard.com/records/A/@" \
-H "accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: sso-key A4r4jH86KGE_9NfjFjmyiRNR48TYN8uKr5:JZCjxA1dtygHEM7iH7NQv8" \
-d "[ { \"data\": \"4.246.223.226\", \"port\": 1, \"priority\": 0, \"protocol\": \"string\", \"service\": \"string\", \"ttl\":3600}]"





