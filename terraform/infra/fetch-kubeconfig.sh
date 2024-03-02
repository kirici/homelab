#!/bin/bash
set -euxo pipefail

scp stream@"$(terraform output --raw ip)":/home/stream/kubeconfig ~/.kube/config

sed -i "s/127.0.0.1/$(terraform output --raw ip)/g" ~/.kube/config
