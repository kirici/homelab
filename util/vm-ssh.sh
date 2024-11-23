#!/bin/bash
set -eu

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"
TF_PATH=$(realpath "${SCRIPTPATH}"/../terraform/infra)

sudo tofu -chdir="${TF_PATH}" refresh -var-file=./example.tfvars &>/dev/null

VM_IP="$(tofu -chdir="${TF_PATH}" output --raw ip)"
ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o "LogLevel ERROR" \
  user@"${VM_IP}"
