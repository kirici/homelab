#!/bin/bash
set -eu

# Global vars
SCRIPTPATH="$(dirname "$(realpath "$0")")"
TF_PATH=$(realpath "${SCRIPTPATH}"/../infra)

id="$(id -u)"
if [ "$id" != "0" ]; then
	echo "Root required."
	exit
fi

pushd "${TF_PATH}"
tofu \
	destroy \
	-var-file=./example.tfvars \
	-auto-approve
popd
