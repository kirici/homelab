#!/bin/bash
set -eux

scp stream@"$(terraform -chdir=infra output --raw ip)":/home/stream/kubeconfig ~/.kube/config

sed -i "s/127.0.0.1/$(terraform -chdir=infra output --raw ip)/g" ~/.kube/config
