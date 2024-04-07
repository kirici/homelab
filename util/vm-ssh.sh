#!/bin/bash
set -eu

# Global vars
VM_IP="$(terraform -chdir=../terraform/infra/ output --raw ip)"

ssh stream@"${VM_IP}"
