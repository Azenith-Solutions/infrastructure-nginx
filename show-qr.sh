#!/bin/sh

CONTAINER="hardwaretech-mobile-expo"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Container '${CONTAINER}' não está rodando."
  echo "Suba o ambiente primeiro: docker compose -f docker-compose.dev.yml up -d"
  exit 1
fi

echo "Aguardando tunnel do Expo ficar pronto (pode levar ~30s)..."

EXPO_URL=""
while [ -z "$EXPO_URL" ]; do
  EXPO_URL=$(docker logs "$CONTAINER" 2>&1 | grep -o 'exp://[^ ]*' | head -1)
  [ -z "$EXPO_URL" ] && sleep 3
done

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
