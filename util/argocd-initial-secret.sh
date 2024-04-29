#!/bin/bash
set -euo pipefail

until kubectl -n argocd get secret argocd-initial-admin-secret -o go-template='{{.data.password|base64decode}}';
do
  printf "."
  sleep 1
done
