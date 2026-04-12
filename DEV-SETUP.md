# HardwareTech — Guia de Provisionamento do Ambiente de Dev

Este guia orienta a equipe sobre como subir o ambiente de desenvolvimento completo da HardwareTech, utilizando o Nginx como orquestrador central de todos os containers. A topologia local espelha o layout de produção no servidor.

---

## Pré-requisitos

| Ferramenta | Versão mínima | Verificar com |
|---|---|---|
| Docker | 24.x | `docker --version` |
| Docker Compose | v2.20+ (plugin) | `docker compose version` |
| Git | 2.x | `git --version` |

> **Espaço em disco**: o build inicial consome ~5 GB (imagens Maven, Node, MySQL, etc.).

---

## Estrutura do ambiente

```
http://localhost/             → Site institucional (catálogo)
http://localhost/manager/     → Sistema de gerenciamento
http://localhost/app/         → App mobile (versão web)
http://localhost/api/v2/      → Backend API REST
http://localhost:15672        → RabbitMQ Management (admin/admin123)
http://localhost:3306         → MySQL (root/H@RDW@RETECH123)
http://localhost:6379         → Redis
```

### Diagrama de serviços

```
                          ┌──────────────────┐
                          │   Nginx (:80)    │
                          └────────┬─────────┘
               ┌──────────┬───────┼────────┬──────────┐
               ▼          ▼       ▼        ▼          │
          /            /manager/  /app/   /api/v2/     │
     ┌─────────┐  ┌─────────┐ ┌───────┐ ┌──────────┐ │
     │ Catálogo│  │ Manager │ │Mobile │ │ Backend  │ │
     │  :80    │  │  :81    │ │ :80   │ │  :8080   │ │
     └─────────┘  └─────────┘ └───────┘ └────┬─────┘ │
                                              │       │
                                     ┌────────┘       │
                                     ▼                │
                               ┌───────────┐          │
                               │  Order    │          │
                               │ Micro :82 │          │
                               └─────┬─────┘          │
                                     │                │
                    ┌────────────────┼────────────────┘
                    ▼                ▼
              ┌──────────┐    ┌───────────┐   ┌───────┐
              │ MySQL    │    │ RabbitMQ  │   │ Redis │
              │  :3306   │    │  :5672    │   │ :6379 │
              └──────────┘    └───────────┘   └───────┘
```

---

## Passo a passo

### 1. Clonar os repositórios

Todos os projetos devem estar na mesma pasta pai, lado a lado:

```bash
mkdir -p ~/projetos/hardwaretech && cd ~/projetos/hardwaretech

git clone <url>/backend-api-rest.git
git clone <url>/order-microservice-api.git
git clone <url>/frontend-website-catalog-app.git
git clone <url>/frontend-manager-app.git
git clone <url>/frontend-mobile-app.git
git clone <url>/infrastructure-nginx.git
```

A estrutura deve ficar assim:

```
hardwaretech/
├── backend-api-rest/
├── order-microservice-api/
├── frontend-website-catalog-app/
├── frontend-manager-app/
├── frontend-mobile-app/
└── infrastructure-nginx/
```

### 2. Configurar variáveis de ambiente

Os backends precisam de arquivos `.env.development` para funcionar. Cada projeto já possui um `.env.example` como referência.

```bash
# Backend API REST
cp backend-api-rest/.env.example backend-api-rest/.env.development
```

Edite `backend-api-rest/.env.development` com os seguintes valores para apontar para os containers:

```env
# Database
DB_URL=jdbc:mysql://mysql-dev:3306/db_hardwaretech_local
DB_USERNAME=root
DB_PASSWORD=H@RDW@RETECH123
DB_DRIVER=com.mysql.cj.jdbc.Driver

# RabbitMQ
RABBITMQ_HOST=rabbitmq-dev
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=admin
RABBITMQ_PASSWORD=admin123

# Redis
CACHE_HOST=redis-dev
CACHE_PORT=6379

# Order Microservice (sobrescrito pelo compose, mas manter como fallback)
ORDER_SERVICE_URL=http://order-microservice:8082

# Messaging - Order Command (backend -> order-microservice)
ORDER_CREATE_EXCHANGE=order.exchange
ORDER_CREATE_QUEUE=order.queue
ORDER_ROUTING_KEY=order.create
ORDER_DLX=order.dlx
ORDER_DLQ=order.dlq

# Messaging - Order Created Event (order-microservice -> backend)
ORDER_CREATED_EXCHANGE=order.created.exchange
ORDER_CREATED_QUEUE=order.created.queue
ORDER_CREATED_ROUTING_KEY=order.created
ORDER_CREATED_DLX=order.created.dlx
ORDER_CREATED_DLQ=order.created.dlq

# JWT
JWT_SECRET=sptech

# Brevo (deixar vazio para dev local)
BREVO_API_KEY=
BREVO_API_URL=

# Gemini (deixar vazio para dev local ou preencher com sua key)
GEMINI_API_KEY=
GEMINI_API_URL=
```

```bash
# Order Microservice
cp order-microservice-api/.env.example order-microservice-api/.env.development
```

Edite `order-microservice-api/.env.development` com os mesmos hostnames de container:

```env
# Database
DB_URL=jdbc:mysql://mysql-dev:3306/db_hardwaretech_local
DB_USERNAME=root
DB_PASSWORD=H@RDW@RETECH123
DB_DRIVER=com.mysql.cj.jdbc.Driver

# RabbitMQ
RABBITMQ_HOST=rabbitmq-dev
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=admin
RABBITMQ_PASSWORD=admin123

# Redis
CACHE_HOST=redis-dev
CACHE_PORT=6379

# Messaging - Order Command
ORDER_CREATE_EXCHANGE=order.exchange
ORDER_CREATE_QUEUE=order.queue
ORDER_CREATE_ROUTING_KEY=order.create
ORDER_ROUTING_KEY=order.create
ORDER_DLX=order.dlx
ORDER_DLQ=order.dlq

# Messaging - Order Created Event
ORDER_CREATED_EXCHANGE=order.created.exchange
ORDER_CREATED_QUEUE=order.created.queue
ORDER_CREATED_ROUTING_KEY=order.created
ORDER_CREATED_DLX=order.created.dlx
ORDER_CREATED_DLQ=order.created.dlq

# JWT
JWT_SECRET=sptech

# Brevo
BREVO_API_KEY=
BREVO_API_URL=

# Gemini
GEMINI_API_KEY=
GEMINI_API_URL=
```

> **Os frontends NÃO precisam de `.env`** para o ambiente orquestrado. O `VITE_API_URL_BASE=/api/v2` já é injetado como build arg no docker-compose, fazendo com que as chamadas à API passem pelo Nginx.

### 3. Subir o ambiente

```bash
cd infrastructure-nginx
docker compose -f docker-compose.dev.yml up --build
```

O primeiro build leva alguns minutos (download de imagens + compilação Maven + build React). Builds seguintes são mais rápidos graças ao cache de camadas do Docker.

#### Ordem de inicialização (automática via `depends_on`)

```
1. mysql-dev, rabbitmq-dev, redis-dev     (infra — sem dependências)
2. backend-api, order-microservice         (aguardam infra ficar healthy)
3. frontend-catalog, frontend-manager,     (build paralelo, sem deps de runtime)
   frontend-mobile-app
4. nginx                                    (aguarda backends + frontends healthy)
```

### 4. Verificar se está tudo rodando

```bash
# Status dos containers
docker compose -f docker-compose.dev.yml ps

# Health check do Nginx
curl http://localhost/nginx-health

# Testar cada rota
curl -I http://localhost/                 # Catálogo
curl -I http://localhost/manager/         # Manager
curl -I http://localhost/app/             # Mobile web
curl -I http://localhost/api/v2/          # Backend API (esperar 401 ou 200 dependendo do endpoint)
```

### 5. Parar o ambiente

```bash
# Parar e manter volumes (dados do MySQL, Redis, RabbitMQ persistem)
docker compose -f docker-compose.dev.yml down

# Parar e apagar TUDO (inclusive dados)
docker compose -f docker-compose.dev.yml down -v
```

---

## Comandos úteis

| Ação | Comando |
|---|---|
| Ver logs de um serviço | `docker compose -f docker-compose.dev.yml logs -f backend-api` |
| Rebuild de um serviço só | `docker compose -f docker-compose.dev.yml up --build frontend-catalog` |
| Entrar no container | `docker compose -f docker-compose.dev.yml exec backend-api sh` |
| Acessar MySQL via CLI | `docker compose -f docker-compose.dev.yml exec mysql-dev mysql -u root -p'H@RDW@RETECH123' db_hardwaretech_local` |
| Ver filas no RabbitMQ | Abrir `http://localhost:15672` (admin / admin123) |
| Limpar cache do Docker | `docker builder prune -f` |

---

## Troubleshooting

### Portas em uso

Se a porta 80 (ou outra) já estiver ocupada:

```bash
# Descobrir o processo
sudo lsof -i :80

# Parar o serviço (exemplo: Apache)
sudo systemctl stop apache2
```

### Backend não conecta no MySQL

O MySQL leva ~30s para ficar healthy. O `depends_on` com `condition: service_healthy` garante que o backend só inicia após o MySQL estar pronto. Se mesmo assim falhar:

```bash
# Verificar se o MySQL está healthy
docker compose -f docker-compose.dev.yml ps mysql-dev

# Ver logs do MySQL
docker compose -f docker-compose.dev.yml logs mysql-dev
```

### Rebuild limpo (nuclear)

Se algo estiver inconsistente:

```bash
docker compose -f docker-compose.dev.yml down -v
docker system prune -f
docker compose -f docker-compose.dev.yml up --build --force-recreate
```

### Mobile App — base path `/app/`

A versão web do mobile app é servida sob `/app/` pelo Nginx. Se assets (JS, CSS, imagens) retornarem 404, pode ser necessário configurar o base path no Expo. No `app.json`, adicione:

```json
{
  "expo": {
    "web": {
      "bundler": "metro",
      "output": "static",
      "baseUrl": "/app"
    }
  }
}
```

E rebuild o container:

```bash
docker compose -f docker-compose.dev.yml up --build frontend-mobile-app
```

---

## Diferenças entre Dev e Prod

| Aspecto | Dev (este compose) | Prod |
|---|---|---|
| Rede | `internal` (bridge local) | `hardwaretech-network` (externa) |
| MySQL | Container local | Servidor dedicado |
| Imagens | Build local (Dockerfile.dev) | GHCR (imagens pré-built) |
| Nginx upstream | 1 instância do backend | Load balanced (2+ instâncias) |
| HTTPS | Sem TLS | TLS com certificado |
| Mobile app | Rota `/app/` no Nginx | Porta 82 direta |
| Volumes | Docker volumes locais | Bind mounts no servidor |
