#!/bin/bash
set -eu

# Global vars
VM_IP="$(terraform -chdir=../terraform/infra/ output --raw ip)"

echo "Waiting for kubeconfig to be available"
until scp stream@"${VM_IP}":/home/stream/kubeconfig ~/.kube/config &>/dev/null;
do
  printf "."
  sleep 1
done

sed -i "s/127.0.0.1/${VM_IP}/g" ~/.kube/config
chmod 600 ~/.kube/config
