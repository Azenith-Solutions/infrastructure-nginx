#!/bin/sh

CONTAINER="hardwaretech-mobile-expo"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Container '${CONTAINER}' não está rodando."
  echo "Suba o ambiente primeiro: docker compose -f docker-compose.dev.yml up -d"
  exit 1
fi

echo "Aguardando Metro Bundler ficar pronto..."
docker logs -f "$CONTAINER" 2>&1 | while IFS= read -r line; do
  echo "$line"
  case "$line" in
    *"Waiting on"*|*"scan"*|*"Scan"*) break ;;
  esac
done

echo ""
echo "QR code gerado acima. Abra o Expo Go no celular e escaneie."
