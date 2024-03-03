#!/bin/bash
set -eu

ssh stream@"$(terraform output --raw ip)"
