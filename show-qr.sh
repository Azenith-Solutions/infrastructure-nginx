#!/bin/sh

CONTAINER="hardwaretech-mobile-expo"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Container '${CONTAINER}' não está rodando."
  echo "Suba o ambiente primeiro: docker compose -f docker-compose.dev.yml up -d"
  exit 1
fi

echo "Aguardando Metro Bundler ficar pronto... (Ctrl+C para sair)"
echo ""
docker logs --tail 0 -f "$CONTAINER" 2>&1
