# 🐳 DOCKER SETUP - VISTORIA VEICULAR

**Data:** 3 de dezembro de 2025  
**Versão:** 1.0  
**Status:** ✅ Pronto para usar

---

## 📋 PRÉ-REQUISITOS

### Obrigatório
- ✅ Docker Desktop (2020.10+)
- ✅ Docker Compose (v1.29+)
- ✅ 8GB RAM disponível
- ✅ 5GB espaço em disco

### Verificar Instalação
```bash
docker --version
docker-compose --version
```

---

## 🚀 INÍCIO RÁPIDO

### 1. Clonar o Repositório
```bash
git clone https://github.com/GuilhermeSantiago921/Vistoria.git
cd Vistoria
```

### 2. Copiar Arquivo .env
```bash
cp .env.docker .env
```

### 3. Executar Setup
```bash
chmod +x docker-setup.sh
./docker-setup.sh
```

Pronto! A aplicação estará rodando em **http://localhost:8000**

---

## 🌐 URLs E ACESSOS

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **Aplicação** | http://localhost:8000 | - |
| **PhpMyAdmin** | http://localhost:8080 | user: `vistoria`, pass: `vistoria_pass` |
| **Redis Commander** | http://localhost:8081 | - |
| **MailHog** | http://localhost:8025 | - |

---

## 📦 SERVIÇOS DOCKER

### App (Laravel)
```yaml
Imagem: php:8.2-cli-alpine
Porta: 8000
Comando: php artisan serve --host=0.0.0.0
```

### MySQL
```yaml
Imagem: mysql:8.0
Porta: 3306
Database: vistoria
User: vistoria
Pass: vistoria_pass
```

### Redis
```yaml
Imagem: redis:7-alpine
Porta: 6379
```

### PhpMyAdmin
```yaml
Imagem: phpmyadmin:latest
Porta: 8080
```

### MailHog
```yaml
Imagem: mailhog/mailhog:latest
Portas: 1025 (SMTP), 8025 (Web)
```

---

## 🎯 COMANDOS PRINCIPAIS

### Iniciar Containers
```bash
docker-compose up -d
```

### Parar Containers
```bash
docker-compose down
```

### Ver Logs da Aplicação
```bash
docker-compose logs -f app
```

### Executar Comando Artisan
```bash
docker-compose exec app php artisan <comando>
```

Exemplos:
```bash
# Criar admin
docker-compose exec app php artisan tinker

# Fazer migration
docker-compose exec app php artisan migrate

# Seeding
docker-compose exec app php artisan db:seed

# Cache clear
docker-compose exec app php artisan cache:clear
```

### Acessar Tinker (REPL)
```bash
docker-compose exec app php artisan tinker
```

### Resetar Banco de Dados
```bash
docker-compose exec app php artisan migrate:fresh --seed
```

### Ver Status dos Containers
```bash
docker-compose ps
```

---

## 🧑‍💻 DESENVOLVIMENTO

### Estrutura de Arquivos
```
Vistoria/
├── app/                 ← Código da aplicação
├── routes/              ← Rotas
├── resources/           ← Views, CSS, JS
├── database/            ← Migrations, seeders
├── public/              ← Assets públicos
├── storage/             ← Logs, uploads
├── docker-compose.yml   ← Configuração Docker
├── Dockerfile           ← Imagem do app
└── .env.docker          ← Variáveis de ambiente
```

### Editar Código Localmente
```bash
# O código fica sincronizado automaticamente
# Edite normalmente no seu editor favorito
# As mudanças refletem automaticamente no container
```

### Instalar Pacotes PHP
```bash
docker-compose exec app composer require vendor/package
```

### Instalar Pacotes Node
```bash
docker-compose exec app npm install
docker-compose exec app npm run build
```

---

## 🐛 TROUBLESHOOTING

### Erro: "Port 8000 already in use"
```bash
# Mudar porta no docker-compose.yml
# Na seção 'app', mudar:
ports:
  - "8001:8000"  # Usar 8001 em vez de 8000
```

### Erro: "Cannot connect to MySQL"
```bash
# Aguardar MySQL estar pronto (pode levar alguns segundos)
docker-compose logs mysql

# Reiniciar MySQL
docker-compose restart mysql
```

### Erro: "File permissions"
```bash
# Resetar permissões
docker-compose exec app chmod -R 777 storage bootstrap/cache
```

### Limpar Tudo e Começar do Zero
```bash
./docker-cleanup.sh
./docker-setup.sh
```

### Ver Logs em Tempo Real
```bash
# App
docker-compose logs -f app

# MySQL
docker-compose logs -f mysql

# Redis
docker-compose logs -f redis

# Todos
docker-compose logs -f
```

---

## 📊 MONITORAMENTO

### CPU e Memória
```bash
docker stats
```

### Espaço em Disco
```bash
docker system df
```

### Limpeza de Espaço
```bash
docker system prune -a --volumes
```

---

## 🧪 TESTES

### Executar Testes
```bash
docker-compose exec app php artisan test
```

### Testes Específicos
```bash
docker-compose exec app php artisan test --filter=CreditSystemTest
```

### Cobertura de Código
```bash
docker-compose exec app php artisan test --coverage
```

---

## 📧 TESTAR EMAILS

1. Abra **http://localhost:8025** (MailHog)
2. Dispare email na aplicação
3. Veja na interface do MailHog

---

## 🔄 ATUALIZAÇÕES

### Atualizar Dependências PHP
```bash
docker-compose exec app composer update
docker-compose exec app composer install
```

### Atualizar Node
```bash
docker-compose exec app npm update
docker-compose exec app npm run build
```

### Rebuild Imagem Docker
```bash
docker-compose build --no-cache
```

---

## 📈 PERFORMANCE

### Otimizações Recomendadas

#### 1. Cache de Assets
```bash
docker-compose exec app php artisan optimize
```

#### 2. Cache de Rotas
```bash
docker-compose exec app php artisan route:cache
```

#### 3. Cache de Config
```bash
docker-compose exec app php artisan config:cache
```

#### 4. Aumentar PHP Memory
No docker-compose.yml:
```yaml
environment:
  PHP_MEMORY_LIMIT: 2G
```

---

## 🔒 SEGURANÇA

### Credenciais Padrão (⚠️ Mudar em Produção)
- **Admin Email:** admin@vistoria.local
- **Admin Pass:** admin123456

### Mudar Credenciais
```bash
# Edit .env
DB_USERNAME=novo_user
DB_PASSWORD=nova_senha_forte

# Rebuild
docker-compose down
docker-compose up -d
```

---

## 🚢 DEPLOY EM PRODUÇÃO

⚠️ **IMPORTANTE:** Docker Compose é para desenvolvimento. Para produção use:
- Docker Swarm
- Kubernetes (K8s)
- Docker Cloud
- Heroku
- AWS ECS

---

## 📞 SUPORTE

### Documentação Adicional
- [Docker Docs](https://docs.docker.com/)
- [Laravel Docs](https://laravel.com/docs)
- [MySQL Docs](https://dev.mysql.com/doc/)
- [Redis Docs](https://redis.io/documentation)

### Verificar Health dos Serviços
```bash
docker-compose ps
```

---

## 🎓 EXEMPLOS DE USO

### Criar Novo Admin via Tinker
```bash
docker-compose exec app php artisan tinker

>>> $user = User::create([
    'name' => 'Admin',
    'email' => 'admin@test.com',
    'password' => Hash::make('password123'),
    'role' => 'admin',
    'inspection_credits' => 1000
]);
```

### Seeder Customizado
```bash
# Criar seeder
docker-compose exec app php artisan make:seeder AdminSeeder

# Executar
docker-compose exec app php artisan db:seed --class=AdminSeeder
```

### Backup do Banco
```bash
docker-compose exec mysql mysqldump -u vistoria -p vistoria > backup.sql
```

### Restore do Banco
```bash
docker-compose exec -T mysql mysql -u vistoria -p vistoria < backup.sql
```

---

## ✅ CHECKLIST DE SETUP

- [ ] Docker instalado
- [ ] Repositório clonado
- [ ] .env copiado
- [ ] docker-setup.sh executado
- [ ] Aplicação acessível em http://localhost:8000
- [ ] PhpMyAdmin acessível em http://localhost:8080
- [ ] Redis pronto em http://localhost:8081
- [ ] Testes passando: `docker-compose exec app php artisan test`

---

**Última Atualização:** 3 de dezembro de 2025  
**Próximas Melhorias:** Adicionar CI/CD, Health Checks, Logging estruturado

