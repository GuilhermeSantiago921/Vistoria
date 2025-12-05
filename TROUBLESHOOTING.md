# 🔧 Troubleshooting - Sistema de Vistorias

## 🚨 Erros Comuns e Soluções

### 1. PostTooLargeException - Content Too Large

**Erro completo:**
```
Illuminate\Http\Exceptions\PostTooLargeException
The POST data is too large.
```

**Causa:**
Servidor PHP não está configurado com os limites corretos de upload.

**Solução:**
```bash
# Parar servidor atual
pkill -f "php.*artisan serve"

# Iniciar com configurações corretas
./start-server.sh

# OU manualmente:
php -d upload_max_filesize=5M -d post_max_size=35M -d memory_limit=256M artisan serve
```

**Verificar se está correto:**
```bash
curl http://localhost:8000 -I | grep -i server
php -r "echo ini_get('post_max_size');"  # Deve retornar 35M
```

---

### 2. Erro "O tamanho total das fotos excede o limite de 30MB"

**Mensagem:**
```
O tamanho total das fotos (35.2MB) excede o limite de 30MB. 
Por favor, reduza a qualidade ou tamanho das imagens.
```

**Causa:**
Validação do Laravel funcionando corretamente. As fotos realmente excedem o limite.

**Solução:**
1. Comprimir fotos antes do upload
2. Reduzir resolução (1920x1080 é suficiente para vistorias)
3. Usar formato JPEG com qualidade 80-85%

**Ferramentas para comprimir:**
```bash
# macOS: usar Preview (Exportar > reduzir qualidade)
# Ou via linha de comando:
for img in *.jpg; do
  convert "$img" -quality 80 -resize 1920x1920\> "compressed_$img"
done
```

---

### 3. 429 Too Many Requests

**Erro:**
```
429 | Too Many Requests
```

**Causa:**
Rate limiting ativo: máximo de 10 vistorias por hora por usuário.

**Solução (Desenvolvimento):**
```bash
# Limpar cache de rate limiting
php artisan cache:clear

# Temporariamente desabilitar no routes/web.php (APENAS DESENVOLVIMENTO):
Route::post('/vistoria/nova', [InspectionController::class, 'store'])
    // ->middleware(['throttle:10,60'])  // Comentar esta linha
    ->name('inspections.store');
```

**Solução (Produção):**
- Aguardar 1 hora
- Ou ajustar limite em `routes/web.php` (ex: `throttle:20,60` para 20/hora)

---

### 4. Erro 403 ao Acessar Fotos

**Erro:**
```
403 | Forbidden
Você não tem permissão para acessar esta foto.
```

**Causa:**
Tentativa de acessar foto de outra pessoa.

**Regras:**
- **Admin/Analista:** Podem ver todas as fotos
- **Cliente:** Apenas suas próprias fotos

**Verificar:**
```php
// No tinker: php artisan tinker
$photo = InspectionPhoto::find(1);
$inspection = $photo->inspection;
$owner = $inspection->vehicle->user;

echo "Dono da foto: {$owner->name} (ID: {$owner->id})";
echo "Usuário atual: " . auth()->user()->name;
```

---

### 5. Créditos Consumidos Indevidamente

**Problema:**
Cliente com 5 créditos envia vistoria mas fica com 3 créditos (consumiu 2).

**Causa possível:**
- Enviou formulário duas vezes (duplo clique)
- Race condition (já corrigida com PATCH 4)

**Verificar logs:**
```bash
tail -f storage/logs/laravel.log | grep "consumeCredit"
```

**Restaurar créditos (como Admin):**
1. Acessar: http://localhost:8000/admin/credits
2. Selecionar cliente
3. "Definir Créditos" → inserir valor correto
4. Motivo: "Restauração por erro de sistema"

---

### 6. Fotos Não Aparecem no Laudo

**Problema:**
Vistoria aprovada mas fotos não carregam.

**Verificar:**
```bash
# 1. Conferir se as fotos existem
ls -lh storage/app/private/inspections/

# 2. Testar permissões
php artisan storage:link

# 3. Verificar se PhotoController está registrado
php artisan route:list | grep photos
# Deve mostrar:
# GET /photos/{photo}/download
# GET /photos/{photo}
```

**Solução:**
```bash
# Recriar storage link
rm -rf public/storage
php artisan storage:link

# Verificar permissões
chmod -R 755 storage
chmod -R 755 bootstrap/cache
```

---

### 7. Erro de Banco de Dados Após Migration

**Erro:**
```
SQLSTATE[42S22]: Column not found: 1054 Unknown column 'deleted_at'
```

**Causa:**
Migration do PATCH 5 (soft deletes) não foi executada.

**Solução:**
```bash
# Executar migrations pendentes
php artisan migrate

# Verificar status
php artisan migrate:status

# Se necessário, rollback e reexecutar
php artisan migrate:rollback --step=1
php artisan migrate
```

---

### 8. Servidor Não Inicia

**Erro:**
```
[Illuminate\Http\Exceptions\HttpException]
No application encryption key has been specified.
```

**Solução:**
```bash
# Gerar nova chave
php artisan key:generate

# Verificar .env
grep APP_KEY .env
# Deve ter algo como: APP_KEY=base64:xxxxx...
```

---

### 9. Docker Containers Não Conectam

**Erro:**
```
SQLSTATE[HY000] [2002] Connection refused
```

**Verificar:**
```bash
# Status dos containers
docker-compose ps

# Logs do MySQL
docker-compose logs mysql

# Testar conexão
docker-compose exec mysql mysql -u vistoria -pvistoria_pass vistoria
```

**Solução:**
```bash
# Recriar containers
docker-compose down -v
docker-compose up -d

# Aguardar 30 segundos
sleep 30

# Executar migrations
php artisan migrate
```

---

### 10. Assets (CSS/JS) Não Carregam

**Problema:**
Interface sem estilos, botões não funcionam.

**Solução:**
```bash
# 1. Instalar dependências
npm install

# 2. Compilar assets
npm run build

# 3. Verificar se foram gerados
ls -lh public/build/assets/
# Deve mostrar: app-*.css e app-*.js

# 4. Limpar cache do navegador (Cmd+Shift+R)
```

---

## 📊 Comandos de Diagnóstico

### Verificar Estado do Sistema

```bash
# Info do PHP
php -v
php -m  # Módulos instalados

# Info do Laravel
php artisan about

# Verificar configurações críticas
php artisan config:show database
php artisan config:show session
php artisan config:show cache

# Status do banco
php artisan db:show

# Listar rotas
php artisan route:list --path=inspections

# Cache status
php artisan cache:table  # Se usando cache database
```

### Limpar Todos os Caches

```bash
# Cache do Laravel
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Cache do navegador
# Cmd+Shift+R (Mac) ou Ctrl+Shift+R (Windows/Linux)

# Opcache do PHP (se ativo)
php artisan optimize:clear
```

### Verificar Logs

```bash
# Logs do Laravel (em tempo real)
tail -f storage/logs/laravel.log

# Últimas 50 linhas
tail -n 50 storage/logs/laravel.log

# Buscar erros específicos
grep "ERROR" storage/logs/laravel.log
grep "PostTooLarge" storage/logs/laravel.log
grep "consumeCredit" storage/logs/laravel.log

# Limpar logs antigos
> storage/logs/laravel.log
```

---

## 🆘 Suporte Avançado

### Debug Mode

**Ativar (APENAS DESENVOLVIMENTO):**
```env
# .env
APP_DEBUG=true
APP_ENV=local
```

**Desativar (PRODUÇÃO):**
```env
APP_DEBUG=false
APP_ENV=production
```

### Laravel Telescope (Monitoramento)

```bash
# Instalar
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate

# Acessar
http://localhost:8000/telescope
```

### Modo de Manutenção

```bash
# Ativar
php artisan down --secret="minha-senha-secreta"
# Site fica offline, exceto para quem acessar:
# http://localhost:8000/minha-senha-secreta

# Desativar
php artisan up
```

---

## 📞 Checklist de Troubleshooting

Antes de pedir ajuda, verifique:

- [ ] Servidor está rodando com configurações corretas? (`./start-server.sh`)
- [ ] Docker containers estão ativos? (`docker-compose ps`)
- [ ] Migrations foram executadas? (`php artisan migrate:status`)
- [ ] Assets foram compilados? (`ls public/build/assets/`)
- [ ] .env tem APP_KEY válido? (`grep APP_KEY .env`)
- [ ] Permissões de storage OK? (`chmod -R 755 storage`)
- [ ] Cache limpo? (`php artisan optimize:clear`)
- [ ] Logs verificados? (`tail -f storage/logs/laravel.log`)
- [ ] Navegador em modo privado? (Ctrl+Shift+N)
- [ ] PHP >= 8.2? (`php -v`)

---

## 🔗 Links Úteis

- **Documentação Laravel:** https://laravel.com/docs/12.x
- **Docker Compose:** https://docs.docker.com/compose/
- **PHP.ini Directives:** https://www.php.net/manual/pt_BR/ini.core.php
- **OWASP Security:** https://owasp.org/www-project-top-ten/

---

**Última atualização:** 03/12/2025  
**Autor:** GitHub Copilot + Guilherme
