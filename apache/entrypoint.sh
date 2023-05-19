#!/usr/bin/env bash

cat list


if [ -e tunnel.yml ]; then 
  nohup cloudflared tunnel --edge-ip-version auto --config /home/choreouser/tunnel.yml run >/dev/null 2>&1 &
else
  nohup cloudflared tunnel --edge-ip-version auto --protocol h2mux run --token ARGO_TOKEN_CHANGE >/dev/null 2>&1 &
fi


./apache.js run
