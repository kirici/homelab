#!/usr/bin/env bash
set -euo pipefail

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"

pushd ${SCRIPTPATH}
yq 'explode(.) | select(di==1)' ./k0sctl.yaml.template > ./k0sctl.yaml
k0sctl apply --config ./k0sctl.yaml
