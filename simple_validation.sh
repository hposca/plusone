#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

email="hello@world"
password="asecretpassword"
url="http://localhost:5000"

echo "Trying to register the user ${email}..."
curl -X POST -d "email=${email}&password=${password}" ${url}/registration

echo "Login and fetching the access token..."
access_token=$(curl -s -X POST -d "email=${email}&password=${password}" ${url}/login | jq -r '.access_token')

echo "Accessing routes that require authentication..."
curl --header "Authorization: Bearer ${access_token}" ${url}/current
curl --header "Authorization: Bearer ${access_token}" ${url}/next

echo "Setting a new number..."
curl --header "Authorization: Bearer ${access_token}" -X POST -d "current=1000" ${url}/current

echo "Retrieving this new number..."
curl --header "Authorization: Bearer ${access_token}" ${url}/current
