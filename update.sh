#!/bin/bash

# Update script for Pessegram
# Gerido pelo Pollux - O Biógrafo do Azar

set -e

cd /root/pessegram

echo "--- [1/3] Pulling latest changes from git ---"
git pull

echo "--- [2/3] Installing dependencies ---"
bundle install

echo "--- [3/3] Restarting Pessegram service ---"
if systemctl restart pessegram; then
    sleep 2
    if systemctl is-active --quiet pessegram; then
        echo "--- Update complete! O bot voltou a vigiar o seu azar. ---"
    else
        echo "--- ERRO: O serviço subiu mas morreu logo em seguida. ---"
        journalctl -u pessegram -n 10 --no-pager
        exit 1
    fi
else
    echo "--- ERRO: O serviço se recusou a subir. Verifique o journalctl. ---"
    exit 1
fi
