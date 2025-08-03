#!/bin/bash
set -eu

kubectl \
	-n argocd \
	wait --for=create \
	--timeout=240s \
	secret/argocd-initial-admin-secret
nohup kubectl \
	-n argocd \
	port-forward \
	services/argocd-server \
	8080:443 \
	&>/dev/null &
