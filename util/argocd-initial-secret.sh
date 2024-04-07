#!/bin/bash
set -euo pipefail

kubectl -n argocd get secret argocd-initial-admin-secret -o yaml | yq .data.password | base64 -d | wl-copy
