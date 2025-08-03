#!/bin/bash
set -eu

k0sctl \
	apply \
	--config "${PROJECT_ROOT}"/infra/k0sctl.yaml
