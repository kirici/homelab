#!/bin/bash
set -eu

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"

k0sctl kubeconfig --config "${SCRIPTPATH}"/../infra/k0sctl.yaml
