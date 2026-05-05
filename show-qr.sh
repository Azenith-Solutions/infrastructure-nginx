#!/bin/sh

CONTAINER="hardwaretech-mobile-expo"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Container '${CONTAINER}' não está rodando."
  echo "Suba o ambiente primeiro: docker compose -f docker-compose.dev.yml up -d"
  exit 1
fi

echo "Aguardando tunnel do Expo ficar pronto (pode levar ~30s)..."
until docker logs "$CONTAINER" 2>&1 | grep -q "Tunnel ready"; do
  sleep 3
done

HOST_URI=$(curl -s http://localhost:8081/ \
  -H "Accept: application/json" \
  -H "Expo-Platform: ios" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['extra']['expoClient']['hostUri'])")

EXPO_URL="exp://${HOST_URI}"

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
