#!/bin/bash
set -eu

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"
TF_PATH=$(realpath "${SCRIPTPATH}"/../terraform/infra)

sudo terraform -chdir="${TF_PATH}" refresh -var-file=./example.tfvars &>/dev/null

echo "Waiting for kubeconfig to be available"
VM_IP="$(terraform -chdir="${TF_PATH}" output --raw ip)"
until scp \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o "LogLevel ERROR" \
  user@"${VM_IP}":/home/user/kubeconfig ~/.kube/config &>/dev/null;
do
  printf "."
  sleep 1
done

sed -i "s/127.0.0.1/${VM_IP}/g" ~/.kube/config
chmod 600 ~/.kube/config
