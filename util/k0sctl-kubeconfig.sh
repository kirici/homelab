#!/bin/bash
set -eu

k0sctl \
	kubeconfig \
	--config "${PROJECT_ROOT}"/infra/k0sctl.yaml
