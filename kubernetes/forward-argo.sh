#!/bin/bash
set -eu

nohup kubectl -n argocd port-forward services/argocd-server 8080:443 &>/dev/null &
