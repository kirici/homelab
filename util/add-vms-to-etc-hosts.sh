#!/usr/bin/env bash
set -euo pipefail

sudo virsh net-dhcp-leases node_net | grep node- | awk -F' ' '{print $5,$6}' | sed 's!/24!!' | sort -k2 | sudo tee -a /etc/hosts
