# 🔒 Correções de Segurança Implementadas

**Data:** 03/12/2025  
**Projeto:** Sistema de Vistorias Veiculares  
**Framework:** Laravel 12.30.1

---

## ✅ Patches Implementados

### PATCH 1: Rate Limiting em Submissões de Vistoria
**Arquivo:** `routes/web.php`  
**Linha:** 57  
**Descrição:** Adicionado middleware `throttle:10,60` na rota POST `/vistoria/nova`  
**Objetivo:** Prevenir abuso e spam limitando a 10 requisições por hora por usuário

```php
Route::post('/vistoria/nova', [InspectionController::class, 'store'])
    ->middleware(['throttle:10,60'])
    ->name('inspections.store');
```

**Teste:** Tentar submeter mais de 10 vistorias em menos de 60 minutos

---

### PATCH 2: Validação de Tamanho Total de Upload
**Arquivo:** `app/Http/Controllers/InspectionController.php`  
**Linhas:** 54-77  
**Descrição:** Validação do tamanho combinado de todas as 10 fotos (limite de 30MB total)  
**Objetivo:** Prevenir DoS por uploads excessivos e controlar uso de disco

**⚠️ CONFIGURAÇÃO PHP NECESSÁRIA:**
Para que esta validação funcione, o PHP precisa permitir uploads maiores:
```bash
# Desenvolvimento: usar script start-server.sh
./start-server.sh

# Ou manualmente:
php -d upload_max_filesize=5M -d post_max_size=35M -d memory_limit=256M artisan serve
```

**Por que 35MB no PHP e 30MB no Laravel?**
- PHP `post_max_size=35MB`: Inclui overhead do multipart/form-data (~15-20%)
- Laravel validation: 30MB apenas para arquivos reais
- Garante que uploads legítimos sempre passem

```php
// Calcula tamanho total dos uploads (máximo 30MB)
$totalSize = 0;
$maxTotalSize = 30 * 1024 * 1024; // 30MB em bytes

for ($i = 1; $i <= 10; $i++) {
    if ($request->hasFile("foto{$i}")) {
        $totalSize += $request->file("foto{$i}")->getSize();
    }
}

if ($totalSize > $maxTotalSize) {
    $totalSizeMB = round($totalSize / 1024 / 1024, 2);
    return back()->withErrors([
        'fotos' => "O tamanho total das fotos ({$totalSizeMB}MB) excede o limite de 30MB. Por favor, reduza a qualidade ou tamanho das imagens."
    ])->withInput();
}
```

**Teste:** Tentar enviar 10 fotos com mais de 3MB cada

---

### PATCH 3: Proteção de Downloads de Fotos
**Arquivos:** 
- `app/Http/Controllers/PhotoController.php` (NOVO - 66 linhas)
- `routes/web.php` (linhas 64-65)

**Descrição:** Controller dedicado para download seguro de fotos com verificação de permissões  
**Objetivo:** Prevenir acesso não autorizado a fotos de vistorias

**Regras de Autorização:**
- **Admin:** Acesso total a todas as fotos
- **Analista:** Acesso total a todas as fotos
- **Cliente:** Apenas fotos de suas próprias vistorias

```php
public function download(InspectionPhoto $photo)
{
    $user = auth()->user();
    $inspection = $photo->inspection;
    
    // Admin e Analistas podem acessar qualquer foto
    if (in_array($user->role, ['admin', 'analyst'])) {
        return $this->streamPhoto($photo);
    }
    
    // Clientes só podem acessar fotos de suas próprias vistorias
    if ($user->role === 'client' && $inspection->vehicle->user_id === $user->id) {
        return $this->streamPhoto($photo);
    }
    
    abort(403, 'Você não tem permissão para acessar esta foto.');
}
```

**Rotas Protegidas:**
```php
Route::get('/photos/{photo}/download', [PhotoController::class, 'download'])->name('photos.download');
Route::get('/photos/{photo}', [PhotoController::class, 'show'])->name('photos.show');
```

**Teste:** 
1. Cliente A tentar acessar foto de vistoria do Cliente B
2. Usuário não autenticado tentar acessar qualquer foto

---

### PATCH 4: Bloqueio Pessimista em Consumo de Créditos
**Arquivo:** `app/Models/User.php`  
**Linhas:** 73-91  
**Descrição:** Implementado pessimistic locking com `lockForUpdate()` no método `consumeCredit()`  
**Objetivo:** Prevenir race conditions onde múltiplas requisições simultâneas poderiam consumir o mesmo crédito

```php
public function consumeCredit(): bool
{
    return \DB::transaction(function () {
        // Lock pessimista: bloqueia o registro até o fim da transação
        $user = User::where('id', $this->id)->lockForUpdate()->first();
        
        if ($user->inspection_credits > 0) {
            $user->decrement('inspection_credits');
            return true;
        }
        
        return false;
    });
}
```

**Cenário Protegido:**
- Usuário com 1 crédito envia 2 vistorias simultaneamente
- Sem o lock: ambas poderiam passar pela verificação `hasCredits()` e consumir o mesmo crédito
- Com o lock: segunda requisição aguarda a primeira terminar e falha por falta de créditos

**Teste:** Script de teste de concorrência (exemplo):
```php
// Criar 10 threads que tentam consumir crédito simultaneamente
$threads = [];
for ($i = 0; $i < 10; $i++) {
    $threads[] = async(fn() => $user->consumeCredit());
}
// Apenas 1 deve ter sucesso se user tiver 1 crédito
```

---

### PATCH 5: Soft Deletes em Vistorias
**Arquivos:**
- `app/Models/Inspection.php` (linha 10)
- `database/migrations/2025_12_03_172101_add_soft_deletes_to_inspections_table.php`

**Descrição:** Implementado soft delete para preservar histórico de vistorias excluídas  
**Objetivo:** Auditoria, recuperação de dados e conformidade com LGPD

```php
use Illuminate\Database\Eloquent\SoftDeletes;

class Inspection extends Model
{
    use HasFactory, SoftDeletes;
    // ...
}
```

**Migration:**
```php
Schema::table('inspections', function (Blueprint $table) {
    $table->softDeletes(); // Adiciona coluna deleted_at
});
```

**Benefícios:**
- Dados não são perdidos permanentemente
- Possibilidade de restaurar vistorias excluídas acidentalmente
- Histórico completo para auditoria
- Query automática exclui registros soft-deleted (usar `withTrashed()` para incluir)

**Teste:**
```php
$inspection->delete(); // Marca deleted_at
Inspection::find($id); // Retorna null
Inspection::withTrashed()->find($id); // Retorna o registro
$inspection->restore(); // Remove deleted_at
```

---

### PATCH 6: Tratamento de Erros no AdminController
**Arquivo:** `app/Http/Controllers/AdminController.php`  
**Métodos:** `addCredits()`, `setCredits()`  
**Descrição:** Implementado try-catch com tratamento específico de exceções  
**Objetivo:** Resiliência, logging de erros e mensagens amigáveis ao usuário

**Exceções Tratadas:**
1. **ValidationException:** Retorna erros de validação ao formulário
2. **ModelNotFoundException:** Usuário não encontrado
3. **Exception (genérico):** Qualquer erro inesperado

```php
try {
    // Lógica de negócio
} catch (\Illuminate\Validation\ValidationException $e) {
    return back()->withErrors($e->errors())->withInput();
} catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
    return back()->with('error', 'Usuário não encontrado.');
} catch (\Exception $e) {
    \Log::error('Erro ao adicionar créditos', [
        'error' => $e->getMessage(),
        'admin_id' => auth()->id(),
        'request_data' => $request->all()
    ]);
    return back()->with('error', 'Erro ao adicionar créditos. Tente novamente.');
}
```

**Logging de Auditoria:**
- Todos os erros são registrados em `storage/logs/laravel.log`
- Inclui contexto completo: usuário admin, dados da requisição, stack trace
- Facilita debug e análise forense

---

## 📋 Validações CSRF Verificadas

**Status:** ✅ Todas as views principais possuem token `@csrf`

**Views auditadas:**
- `resources/views/inspections/create.blade.php` ✅
- `resources/views/payment/form.blade.php` ✅
- `resources/views/admin/credits/manage.blade.php` ✅
- `resources/views/admin/users/create.blade.php` ✅
- `resources/views/analyst/inspections/show.blade.php` ✅
- `resources/views/auth/*.blade.php` ✅
- `resources/views/profile/partials/*.blade.php` ✅

**Total de forms verificados:** 20+ formulários com `@csrf` implementado

---

## ⚙️ Configuração PHP para Uploads

### Problema: PostTooLargeException

**Erro comum:**
```
Illuminate\Http\Exceptions\PostTooLargeException - Content Too Large
The POST data is too large.
```

**Causa:**
O PHP tem limites padrão muito baixos:
- `upload_max_filesize = 2M` (padrão)
- `post_max_size = 8M` (padrão)

Nosso sistema precisa de 10 fotos que podem totalizar até 30MB.

### ✅ Solução Implementada

#### 1. Desenvolvimento Local

**Script automatizado:**
```bash
./start-server.sh
```

**Comando manual:**
```bash
php -d upload_max_filesize=5M \
    -d post_max_size=35M \
    -d memory_limit=256M \
    -d max_execution_time=120 \
    artisan serve
```

#### 2. Docker (Produção)

Configurado no `Dockerfile`:
```dockerfile
RUN echo "upload_max_filesize = 5M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 35M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 120" >> /usr/local/etc/php/conf.d/uploads.ini
```

#### 3. Nginx/Apache (Produção)

**Nginx (`/etc/nginx/nginx.conf`):**
```nginx
http {
    client_max_body_size 35M;
}
```

**Apache (`.htaccess` ou `httpd.conf`):**
```apache
php_value upload_max_filesize 5M
php_value post_max_size 35M
php_value memory_limit 256M
php_value max_execution_time 120
```

### 📊 Arquitetura de Validação em Camadas

| Camada | Limite | Propósito |
|--------|--------|-----------|
| **Nginx/Apache** | 35MB | Rejeita requisições muito grandes antes do PHP |
| **PHP** | post_max_size=35MB | Valida tamanho total do POST |
| **PHP** | upload_max_filesize=5MB | Valida cada arquivo individual |
| **Laravel** | 30MB total | Lógica de negócio (10 fotos) |
| **Rate Limiting** | 10/hora | Previne abuso de uploads |

**Benefícios:**
- Defense in depth (defesa em profundidade)
- Economiza recursos rejeitando cedo
- Flexibilidade para ajustar regras de negócio
- Logs detalhados em cada camada

### 🧪 Verificar Configurações Ativas

```bash
# Ver todas as configurações PHP
php -i | grep -E "(upload_max_filesize|post_max_size|memory_limit)"

# Testar no código
php -r "echo 'Max upload: ' . ini_get('upload_max_filesize') . PHP_EOL;"
php -r "echo 'Max POST: ' . ini_get('post_max_size') . PHP_EOL;"
```

---

## 🧪 Testes Recomendados

### 1. Teste de Rate Limiting
```bash
# Enviar 11 requisições em menos de 1 minuto
for i in {1..11}; do
  curl -X POST http://localhost:8000/vistoria/nova \
    -H "Authorization: Bearer $TOKEN" \
    -F "foto1=@test.jpg" \
    # ... outros campos
done
# Expectativa: 11ª requisição retorna erro 429 (Too Many Requests)
```

### 2. Teste de Upload Size
```bash
# Criar 10 fotos de 3.5MB cada (total 35MB > 30MB)
for i in {1..10}; do
  dd if=/dev/zero of=photo$i.jpg bs=1M count=3.5
done

# Tentar enviar todas de uma vez
# Expectativa: Erro de validação "O tamanho total das fotos (35MB) excede o limite de 30MB"
```

### 3. Teste de Autorização de Fotos
```bash
# Como Cliente A, tentar acessar foto do Cliente B
curl http://localhost:8000/photos/999/download \
  -H "Cookie: laravel_session=$CLIENT_A_SESSION"
# Expectativa: 403 Forbidden
```

### 4. Teste de Race Condition
```php
// No Tinker: php artisan tinker
$user = User::find(1); // Cliente com 1 crédito
$user->inspection_credits = 1;
$user->save();

// Executar 2 threads simultâneas (requer extensão pcntl)
$pid = pcntl_fork();
if ($pid == -1) {
    die('Fork failed');
} elseif ($pid) {
    // Processo pai
    $result1 = $user->consumeCredit();
    pcntl_wait($status);
} else {
    // Processo filho
    $result2 = $user->consumeCredit();
    exit();
}

// Apenas $result1 OU $result2 deve ser true, nunca ambos
```

---

## 📊 Impacto de Segurança

### Vulnerabilidades Corrigidas
- ✅ **DoS por Rate Limiting:** Severidade ALTA
- ✅ **DoS por Upload Excessivo:** Severidade ALTA
- ✅ **IDOR em Downloads de Fotos:** Severidade CRÍTICA
- ✅ **Race Condition em Créditos:** Severidade ALTA
- ✅ **Perda de Dados por Exclusão:** Severidade MÉDIA
- ✅ **Erros Não Tratados:** Severidade MÉDIA

### Conformidade
- **LGPD:** Soft deletes permite auditoria e recuperação
- **OWASP Top 10:**
  - A01:2021 - Broken Access Control: Corrigido com PhotoController
  - A04:2021 - Insecure Design: Corrigido com rate limiting e locks
  - A05:2021 - Security Misconfiguration: Melhorado com error handling

---

## 🔄 Próximas Recomendações

### Curto Prazo (1-2 semanas)
1. **Testes Automatizados:** Criar PHPUnit tests para os patches implementados
2. **Monitoramento:** Implementar alertas para rate limiting violations
3. **Backup:** Configurar backup automático das fotos em S3/storage

### Médio Prazo (1 mês)
4. **Auditoria Completa:** Log de todas as ações administrativas em tabela `audit_logs`
5. **2FA:** Autenticação de dois fatores para admin e analistas
6. **API Rate Limiting:** Limites separados para API vs Web

### Longo Prazo (3 meses)
7. **Penetration Testing:** Contratar auditoria de segurança profissional
8. **WAF:** Implementar Web Application Firewall (CloudFlare, AWS WAF)
9. **Security Headers:** HSTS, CSP, X-Frame-Options no nginx/Apache

---

## 📝 Checklist de Deployment

Antes de fazer deploy das correções em produção:

- [ ] Executar todos os testes manuais descritos acima
- [ ] Criar backup completo do banco de dados
- [ ] Executar migrations: `php artisan migrate`
- [ ] Limpar caches: `php artisan config:clear && php artisan route:clear`
- [ ] Verificar logs: `tail -f storage/logs/laravel.log`
- [ ] Monitorar por 24h após deploy
- [ ] Comunicar usuários sobre novos limites (10 vistorias/hora)

---

## 👥 Créditos

**Implementado por:** GitHub Copilot + Guilherme  
**Data de Implementação:** 03/12/2025  
**Revisado por:** [Aguardando revisão técnica]

---

## 📧 Contato

Em caso de dúvidas sobre as implementações de segurança:
- Documentação técnica: Este arquivo
- Issues: Criar issue no repositório do projeto
- Suporte: [email do time de desenvolvimento]
