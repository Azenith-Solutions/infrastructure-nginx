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
BUNDLE_URL="http://localhost:8081/node_modules/expo-router/entry.bundle?platform=android&dev=true&hot=false&lazy=true&transform.engine=hermes&transform.bytecode=1&transform.routerRoot=app"

echo "Aguardando Metro Bundler ficar pronto..."
until docker logs "$CONTAINER" 2>&1 | grep -q "Waiting on"; do
  sleep 2
done

echo "Pré-compilando bundle nativo (aguarde, isso evita timeout no Expo Go)..."
curl -s --max-time 120 "$BUNDLE_URL" -o /dev/null
echo "Bundle pronto."

echo ""
echo "================================================================"
echo "  Expo Go  →  $EXPO_URL"
echo "  (ou abra o Expo Go e digite a URL acima manualmente)"
echo "================================================================"
echo ""

python3 - "$EXPO_URL" <<'EOF'
import sys, qrcode
qr = qrcode.QRCode(border=2)
qr.add_data(sys.argv[1])
qr.make(fit=True)
qr.print_ascii(invert=True)
EOF
