#!/bin/bash
set -eu

kubectl apply --recursive -f argocd/apps
