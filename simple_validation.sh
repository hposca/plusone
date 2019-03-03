#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

url="http://localhost:5000"

email="hello@world"
password="asecretpassword"

echo "Trying to register the user ${email}..."
curl -X POST -d "email=${email}&password=${password}" ${url}/registration
echo ""

echo "Login and fetching the access token..."
access_token=$(curl -s -X POST -d "email=${email}&password=${password}" ${url}/login | jq -r '.access_token')
echo ""

echo "Accessing routes that require authentication..."
echo ""

echo "The current number is: "
curl -s --header "Authorization: Bearer ${access_token}" ${url}/current | jq '.number'
echo ""

echo "Let's get the next number..."
curl -s --header "Authorization: Bearer ${access_token}" ${url}/next | jq '.number'
echo ""

echo "Retrieving this new number..."
curl -s --header "Authorization: Bearer ${access_token}" ${url}/current | jq '.number'
echo ""

echo "Setting a new number..."
curl -s --header "Authorization: Bearer ${access_token}" -X PUT -d "current=1000" ${url}/current | jq '.message'
echo ""

echo "Retrieving this new number..."
curl -s --header "Authorization: Bearer ${access_token}" ${url}/current | jq '.number'
echo ""

echo "Let's get the next number..."
curl -s --header "Authorization: Bearer ${access_token}" ${url}/next | jq '.number'
echo ""

echo "Trying to set a negative number..."
curl -s --header "Authorization: Bearer ${access_token}" -X PUT -d "current=-1234" ${url}/current | jq '.message'
echo ""

echo ""
echo ""
echo "Now as another user..."
echo ""
echo ""

email="another@user"
password="anothersecretpassword"

echo "Trying to register the user ${email}..."
curl -X POST -d "email=${email}&password=${password}" ${url}/registration
echo ""

echo "Login and fetching the access token..."
access_token=$(curl -s -X POST -d "email=${email}&password=${password}" ${url}/login | jq -r '.access_token')
echo ""

echo "Accessing routes that require authentication..."
echo ""

echo "The current number is: "
curl -s --header "Authorization: Bearer ${access_token}" ${url}/current | jq '.number'
echo ""

echo "Let's get the next number..."
curl -s --header "Authorization: Bearer ${access_token}" ${url}/next | jq '.number'
echo ""

echo "Retrieving this new number..."
curl -s --header "Authorization: Bearer ${access_token}" ${url}/current | jq '.number'
echo ""

echo "Setting a new number..."
curl -s --header "Authorization: Bearer ${access_token}" -X PUT -d "current=333" ${url}/current | jq '.message'
echo ""

echo "Retrieving this new number..."
curl -s --header "Authorization: Bearer ${access_token}" ${url}/current | jq '.number'
echo ""

echo "Let's get the next number..."
curl -s --header "Authorization: Bearer ${access_token}" ${url}/next | jq '.number'
echo ""

echo "Trying to set a negative number..."
curl -s --header "Authorization: Bearer ${access_token}" -X PUT -d "current=-5678" ${url}/current | jq '.message'
echo ""
