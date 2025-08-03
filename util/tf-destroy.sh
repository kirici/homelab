#!/bin/bash
set -eu

# Global vars
TF_PATH="${PROJECT_ROOT}"/infra

id="$(id -u)"
if [[ "${id}" != "0" ]]; then
	echo "Root required."
	exit
fi

pushd "${TF_PATH}"
tofu \
	destroy \
	-var-file=./example.tfvars \
	-auto-approve
popd
