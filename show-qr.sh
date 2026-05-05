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
echo "================================================================"
echo "  Expo Go  →  $EXPO_URL"
echo "  (ou abra o Expo Go e digite a URL acima manualmente)"
echo "================================================================"
echo ""

if python3 -c "import qrcode" 2>/dev/null; then
  python3 - "$EXPO_URL" <<'EOF'
import sys, qrcode
qr = qrcode.QRCode(border=2)
qr.add_data(sys.argv[1])
qr.make(fit=True)
qr.print_ascii(invert=True)
EOF
elif pip3 install --quiet qrcode 2>/dev/null; then
  python3 - "$EXPO_URL" <<'EOF'
import sys, qrcode
qr = qrcode.QRCode(border=2)
qr.add_data(sys.argv[1])
qr.make(fit=True)
qr.print_ascii(invert=True)
EOF
else
  echo "Instale o Python qrcode para gerar o QR code: pip3 install qrcode"
  echo "Ou acesse manualmente pelo Expo Go digitando a URL acima."
fi
