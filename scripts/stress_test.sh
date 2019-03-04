#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

url="http://${LOAD_BALANCER}"

email="stress@test"
password="asecretpassword"

echo "Trying to register the user ${email}..."
curl -X POST -d "email=${email}&password=${password}" ${url}/registration
echo ""

echo "Login and fetching the access token..."
access_token=$(curl -s -X POST -d "email=${email}&password=${password}" ${url}/login | jq -r '.access_token')
echo ""

for i in $(seq 1 1000) ; do
  echo "Let's get the next number..."
  curl -s --header "Authorization: Bearer ${access_token}" ${url}/next | jq '.number'
  echo ""
done
