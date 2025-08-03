#!/bin/bash
set -eu

kubectl apply \
	--recursive \
	-f "${PROJECT_ROOT}"/k8s/argocd/apps
