#!/bin/bash
set -eu

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"
TF_PATH=$(realpath "${SCRIPTPATH}"/../terraform/infra)

sudo terraform -chdir="${TF_PATH}" refresh &>/dev/null

VM_IP="$(terraform -chdir="${TF_PATH}" output --raw ip)"
ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o "LogLevel ERROR" \
  stream@"${VM_IP}"
