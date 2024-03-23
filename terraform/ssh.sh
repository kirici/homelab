#!/bin/bash
set -eu

ssh stream@"$(terraform -chdir=infra output --raw ip)"
