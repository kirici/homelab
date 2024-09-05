#!/usr/bin/env sh

caddy run -c ./caddyfile > log.json 2>&1 &
