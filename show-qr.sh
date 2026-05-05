#!/bin/sh

CONTAINER="hardwaretech-mobile-expo"
ENV_FILE="$(dirname "$0")/.env"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Container '${CONTAINER}' não está rodando."
  echo "Suba o ambiente primeiro: docker compose -f docker-compose.dev.yml up -d"
  exit 1
fi

HOST_IP=$(grep '^HOST_IP=' "$ENV_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d ' \r')

if [ -z "$HOST_IP" ]; then
  echo "HOST_IP não encontrado em .env. Preencha o arquivo .env antes de continuar."
  exit 1
fi

EXPO_URL="exp://${HOST_IP}:8081"

echo "Aguardando Metro Bundler ficar pronto..."
until docker logs "$CONTAINER" 2>&1 | grep -q "Waiting on"; do
  sleep 2
done

echo ""
echo "Abra o Expo Go e escaneie:"
echo "$EXPO_URL"
echo ""
npx --yes qrcode-terminal "$EXPO_URL"
