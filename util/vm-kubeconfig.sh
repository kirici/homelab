#!/bin/bash
set -eu

# spin anim
spin='⣾⣽⣻⢿⡿⣟⣯⣷'
i=0

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"
TF_PATH=$(realpath "${SCRIPTPATH}"/../terraform/infra)

sudo terraform -chdir="${TF_PATH}" refresh -var-file=./example.tfvars &>/dev/null

VM_IP="$(terraform -chdir="${TF_PATH}" output --raw ip)"
until scp \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o "LogLevel ERROR" \
  user@"${VM_IP}":/home/user/kubeconfig ~/.kube/config &>/dev/null;
do
  i=$(( (i-1) %8 ))
  printf "\rWaiting for kubeconfig to be available ${spin:$i:1}"
  sleep .25
done

sed -i "s/127.0.0.1/${VM_IP}/g" ~/.kube/config
chmod 600 ~/.kube/config
