#!/bin/bash
set -eu

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"
TF_PATH=$(realpath "${SCRIPTPATH}"/../terraform/infra)

id="$(id -u)"
if [ "$id" != "0" ]; then
  echo "Root required."
  exit
fi

terraform \
  -chdir="${TF_PATH}" \
  apply \
  -var-file=./example.tfvars \
  -auto-approve
