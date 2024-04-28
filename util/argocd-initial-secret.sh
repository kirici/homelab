#!/bin/bash
set -euo pipefail

kubectl -n argocd get secret argocd-initial-admin-secret -o go-template='{{.data.password|base64decode}}'
