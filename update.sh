#!/bin/bash

# Update script for Pessegram
# Gerido pelo Pollux - O Biógrafo do Azar

# Se um comando falhar, o script para imediatamente (prevenindo o caos descontrolado)
set -e

echo "--- [1/3] Pulling latest changes from git ---"
git pull

echo "--- [2/3] Installing dependencies ---"
bundle install

echo "--- [3/3] Restarting Pessegram service ---"
# O sistema pode pedir sua senha aqui, mestre. Tente não errar.
if sudo systemctl restart pessegram; then
    echo "--- Update complete! O bot voltou a vigiar o seu azar. ---"
else
    echo "--- ERRO: O serviço se recusou a subir. Verifique o journalctl. ---"
    exit 1
fi
