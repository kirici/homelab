#!/bin/bash
set -eu

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"

kubectl apply --recursive -f "$(realpath "${SCRIPTPATH}"/../k8s/argocd/apps)"
