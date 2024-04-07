#!/bin/bash
set -eu

kubectl apply --recursive -f ../kubernetes/argocd/apps
