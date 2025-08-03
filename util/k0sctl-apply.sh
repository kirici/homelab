#!/bin/bash
set -eu

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"

k0sctl apply --config "${SCRIPTPATH}"/../infra/k0sctl.yaml
