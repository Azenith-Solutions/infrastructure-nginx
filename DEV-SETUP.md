# HardwareTech — Guia de Provisionamento do Ambiente de Dev

---

## Pré-requisitos

| Ferramenta | Versão mínima | Verificar com |
|---|---|---|
| Docker | 24.x | `docker --version` |
| Docker Compose | v2.20+ (plugin) | `docker compose version` |
| Git | 2.x | `git --version` |

> **Espaço em disco**: o build inicial consome ~5 GB (imagens Maven, Node, MySQL, etc.).

---

## O que sobe com esse ambiente

```
http://localhost/             → Catálogo (site público)
http://localhost/manager/     → Sistema de gerenciamento (admin)
http://localhost/app/         → App mobile (versão web, abre no browser)
http://localhost/api/v2/      → Backend API REST
http://localhost/ai/          → AI Chatbot Service
http://localhost:5678         → N8N (automação de workflows)
http://localhost:8081         → Expo Metro Server (QR code para testar no celular)
http://localhost:15672        → RabbitMQ (admin / admin123)
http://localhost:3306         → MySQL (root / H@RDW@RETECH123)
http://localhost:6379         → Redis
```

### Como o tráfego flui

```
                         ┌──────────────────┐
                         │   Nginx (:80)    │
                         └────────┬─────────┘
       ┌──────────┬───────┬───────┼────────┬──────────┐
       ▼          ▼       ▼       ▼        ▼          │
  /         /manager/ /app/  /api/v2/    /ai/         │
┌───────┐ ┌───────┐ ┌─────┐ ┌───────┐ ┌──────────┐   │
│Catál. │ │Manager│ │Mobi.│ │Backend│ │AI Chatbot│   │
└───────┘ └───────┘ └─────┘ └───┬───┘ └──────────┘   │
                                │                     │
                         ┌──────┘                     │
                         ▼                            │
                   ┌───────────┐                      │
                   │  Order    │                      │
                   │ Micro :82 │                      │
                   └─────┬─────┘                      │
                         │                            │
        ┌────────────────┼────────────────────────────┘
        ▼                ▼               ▼
  ┌──────────┐    ┌───────────┐    ┌───────┐
  │  MySQL   │    │ RabbitMQ  │    │ Redis │
  └──────────┘    └───────────┘    └───────┘

Expo Metro Server (:8081) — independente do Nginx, acesso via Expo Go no celular
N8N (:5678)               — independente do Nginx, acesso direto pelo browser
```

---

## Dev vs Prod — o que muda no mobile

O app mobile existe em dois formatos distintos, e cada ambiente usa um deles:

**No browser (dev e prod):** O Expo exporta o app como site estático. O Nginx serve em `/app/`. Funciona em qualquer browser, inclusive no celular — mas sem acesso a recursos nativos como câmera.

**No celular como app nativo:**
- **Dev →** Expo Go + tunnel. O servidor Metro roda no container, gera um QR code. Você escaneia com o Expo Go e o app carrega ao vivo com hot reload. Ideal para testar câmera, QR code, etc.
- **Prod →** App instalado via App Store / Play Store, gerado com `eas build`. Sem Expo Go, sem servidor — o app já está compilado no celular e chama a API de produção diretamente.

---

## Situação do seu ambiente — por onde começar

Antes de qualquer coisa, identifique em qual situação você está:

---

### Situação A — Primeira vez (ambiente zerado)

Siga o passo a passo completo abaixo a partir da seção **1. Clonar os repositórios**.

---

### Situação B — Já tem containers de versões anteriores

Se você já subiu o ambiente antes das correções do Expo (maio/2026), o volume de `node_modules` do container Expo está desatualizado. Rode:

```bash
cd infrastructure-nginx
docker compose -f docker-compose.dev.yml down
docker volume rm hardwaretech-dev_mobile-expo-modules
docker compose -f docker-compose.dev.yml up --build -d
```

---

### Situação C — Ambiente parcialmente rodando

Alguns containers estão de pé mas outros não. O comando abaixo sobe o que está faltando sem derrubar o que já está:

```bash
cd infrastructure-nginx
docker compose -f docker-compose.dev.yml up --build -d
```

---

## Passo a passo

### 1. Clonar os repositórios

Todos os projetos devem estar na mesma pasta pai:

```bash
mkdir -p ~/projetos/hardwaretech && cd ~/projetos/hardwaretech

git clone git@github.com:Azenith-Solutions/backend-api-rest.git
git clone git@github.com:Azenith-Solutions/order-microservice-api.git
git clone git@github.com:Azenith-Solutions/frontend-website-catalog-app.git
git clone git@github.com:Azenith-Solutions/frontend-manager-app.git
git clone git@github.com:Azenith-Solutions/frontend-mobile-app.git
git clone git@github.com:Azenith-Solutions/ai-chatbot-service.git
git clone git@github.com:Azenith-Solutions/n8n.git
git clone git@github.com:Azenith-Solutions/infrastructure-nginx.git
```

```
hardwaretech/
├── backend-api-rest/
├── order-microservice-api/
├── frontend-website-catalog-app/
├── frontend-manager-app/
├── frontend-mobile-app/
├── ai-chatbot-service/
├── n8n/
└── infrastructure-nginx/
```

### 2. Configurar variáveis de ambiente

#### infrastructure-nginx (orquestrador)

```bash
cd infrastructure-nginx
cp .env.example .env
```

Edite `.env`:

```env
# IP da sua máquina na rede local
# Linux:  ip route get 1 | awk '{print $7; exit}'
# macOS:  ipconfig getifaddr en0
HOST_IP=192.168.x.x

# Token do Expo para o tunnel (expo.dev → Account Settings → Access Tokens)
EXPO_TOKEN=seu_token_aqui
```

> O `HOST_IP` é necessário para que o celular (via Expo Go) saiba onde está a API. O `EXPO_TOKEN` permite que o tunnel do Expo funcione sem login interativo dentro do container.

#### Backend API REST

```bash
cp backend-api-rest/.env.example backend-api-rest/.env.development
```

Preencha `backend-api-rest/.env.development`:

```env
DB_URL=jdbc:mysql://mysql-dev:3306/db_hardwaretech_local
DB_USERNAME=root
DB_PASSWORD=H@RDW@RETECH123
DB_DRIVER=com.mysql.cj.jdbc.Driver

RABBITMQ_HOST=rabbitmq-dev
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=admin
RABBITMQ_PASSWORD=admin123

CACHE_HOST=redis-dev
CACHE_PORT=6379

ORDER_SERVICE_URL=http://order-microservice:8082

ORDER_CREATE_EXCHANGE=order.exchange
ORDER_CREATE_QUEUE=order.queue
ORDER_ROUTING_KEY=order.create
ORDER_DLX=order.dlx
ORDER_DLQ=order.dlq

ORDER_CREATED_EXCHANGE=order.created.exchange
ORDER_CREATED_QUEUE=order.created.queue
ORDER_CREATED_ROUTING_KEY=order.created
ORDER_CREATED_DLX=order.created.dlx
ORDER_CREATED_DLQ=order.created.dlq

JWT_SECRET=sptech
BREVO_API_KEY=
BREVO_API_URL=
GEMINI_API_KEY=
GEMINI_API_URL=
```

#### Order Microservice

```bash
cp order-microservice-api/.env.example order-microservice-api/.env.development
```

Preencha com os mesmos valores de banco, RabbitMQ, Redis e mensageria do backend acima.

#### AI Chatbot Service

```bash
cp ai-chatbot-service/.env.example ai-chatbot-service/.env
```

Preencha a chave do LLM (padrão: Gemini):

```env
LLM_PROVIDER=gemini/gemini-2.0-flash
LLM_API_KEY=AIzaSy...sua-chave-aqui...
```

> Os frontends web (catálogo, manager) **não precisam de `.env`** — a URL da API é injetada como build arg no docker-compose.

#### N8N

```bash
cd n8n
cp credentials-mysql.example.json credentials-mysql.json
```

Substitua `SUBSTITUA_PELA_SENHA_DO_BANCO` por `H@RDW@RETECH123` no arquivo. Após subir o ambiente, importe as credenciais e o workflow pela interface em `http://localhost:5678`.

### 3. Subir o ambiente

```bash
cd infrastructure-nginx
docker compose -f docker-compose.dev.yml up --build
```

O primeiro build leva alguns minutos. Os seguintes são mais rápidos graças ao cache do Docker.

#### Ordem de inicialização (automática)

```
1. MySQL, RabbitMQ, Redis          → infra base
2. Backend API, Order Microservice → aguardam a infra ficar healthy
3. Frontends, AI Chatbot, N8N      → build paralelo
4. Expo Metro Server               → sobe junto, inicia o tunnel
5. Nginx                           → último, aguarda todos os serviços healthy
```

### 4. Testar no celular com Expo Go

Instale o **Expo Go** no celular (App Store / Play Store).

Após o ambiente subir, gere o QR code com o script disponível no repositório:

```bash
cd infrastructure-nginx
./show-qr.sh
```

O script aguarda o Metro Bundler ficar pronto e exibe o QR code no terminal. Escaneie com o Expo Go — o app abre ao vivo com hot reload, qualquer alteração no código reflete imediatamente no celular sem rebuild.

> Se preferir acompanhar todos os logs do container: `docker logs -f hardwaretech-mobile-expo`

### 5. Verificar se está tudo rodando

```bash
docker compose -f docker-compose.dev.yml ps

curl http://localhost/nginx-health   # deve retornar "nginx ok"
curl -I http://localhost/            # Catálogo
curl -I http://localhost/manager/    # Manager
curl -I http://localhost/app/        # Mobile web
curl -I http://localhost/api/v2/categorys  # API (200 ou 401)
```

### 6. Parar o ambiente

```bash
# Para e mantém os dados (MySQL, Redis, RabbitMQ)
docker compose -f docker-compose.dev.yml down

# Para e apaga tudo, inclusive banco de dados
docker compose -f docker-compose.dev.yml down -v
```

---

## Comandos úteis

| Ação | Comando |
|---|---|
| Ver QR code do Expo | `docker logs -f hardwaretech-mobile-expo` |
| Ver logs de qualquer serviço | `docker compose -f docker-compose.dev.yml logs -f <serviço>` |
| Rebuild de um serviço específico | `docker compose -f docker-compose.dev.yml up --build <serviço>` |
| Entrar no container | `docker compose -f docker-compose.dev.yml exec backend-api sh` |
| Acessar MySQL via CLI | `docker compose -f docker-compose.dev.yml exec mysql-dev mysql -u root -p'H@RDW@RETECH123' db_hardwaretech_local` |
| Rodar seed de dados mockados | `docker compose -f docker-compose.dev.yml exec mysql-dev mysql -u root -p'H@RDW@RETECH123' db_hardwaretech_local < seed.sql` |
| Ver filas no RabbitMQ | `http://localhost:15672` (admin / admin123) |
| Limpar cache do Docker | `docker builder prune -f` |

---

## Troubleshooting

### Portas em uso

```bash
sudo lsof -i :80    # descobrir o processo
sudo systemctl stop apache2  # exemplo para liberar a porta 80
```

### Backend não conecta no MySQL

O MySQL leva ~30s para ficar healthy. O `depends_on` garante a ordem certa. Se mesmo assim falhar:

```bash
docker compose -f docker-compose.dev.yml logs mysql-dev
docker compose -f docker-compose.dev.yml ps mysql-dev
```

### Expo não gera QR code / tunnel falha

Verifique se o `EXPO_TOKEN` está preenchido no `.env` do `infrastructure-nginx`. Sem ele, o Expo tenta fazer login interativo e trava.

```bash
docker logs hardwaretech-mobile-expo 2>&1 | head -30
```

### Dependências do Expo desatualizadas após rebuild

O container Expo usa um **volume nomeado** (`mobile-expo-modules`) para persistir o `node_modules` entre reinicializações — isso acelera o startup. O tradeoff é que o Docker **não atualiza o volume automaticamente** quando a imagem é reconstruída com `--build`.

Para garantir que o volume reflita o `package.json` atual (ex: após adicionar ou remover pacotes), destrua o volume e recrie:

```bash
docker compose -f docker-compose.dev.yml down
docker volume rm hardwaretech-dev_mobile-expo-modules
docker compose -f docker-compose.dev.yml up --build frontend-mobile-expo
```

> O `entrypoint.dev.sh` do container já roda `npm install` automaticamente na inicialização, então após a recriação do volume as dependências são sempre instaladas frescas.

### Rebuild limpo

```bash
docker compose -f docker-compose.dev.yml down -v
docker system prune -f
docker compose -f docker-compose.dev.yml up --build --force-recreate
```

---

## Dev vs Prod — resumo técnico

| | Dev | Prod |
|---|---|---|
| **Web (browser)** | `http://localhost/` via Nginx | `https://dominio.com/` via Nginx + TLS |
| **Mobile no browser** | `http://localhost/app/` via Nginx | `https://dominio.com/app/` via Nginx + TLS |
| **Mobile nativo** | Expo Go + QR code (Metro Server) | App instalado via App Store / Play Store (`eas build`) |
| **API no mobile nativo** | `http://[HOST_IP]/api/v2` (rede local) | `https://api.dominio.com/api/v2` (HTTPS) |
| **Atualização do app nativo** | Hot reload imediato | `eas update` (OTA) ou nova versão na loja |
| **MySQL** | Container local | Servidor dedicado |
| **Imagens Docker** | Build local | GHCR (imagens pré-built) |
| **Nginx upstream** | 1 instância do backend | Load balanced (2+ instâncias) |
