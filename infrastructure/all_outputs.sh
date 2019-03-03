#!/usr/bin/env sh

# Displays all the outpus from terrafom
# Be aware that anything that is on the terraform state file will appear, THIS INCLUDES CREDENTIALS

echo "Outputs on the root:"
terraform output
echo ""

for module in $(terraform show | grep module | awk -F'.' '{ print $2 }' | uniq); do
  echo "Outputs for ${module} :"
  terraform output --module "${module}"
  echo ""
done
