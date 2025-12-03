# ✅ CHECKLIST PRÁTICO - IMPLEMENTAÇÃO DE PATCHES

**Data:** 3 de dezembro de 2025  
**Versão:** v1.0  
**Status:** Pronto para implementação

---

## 🎯 OBJETIVO

Este checklist é um guia passo-a-passo para implementar os 7 patches de segurança recomendados.

---

## 📋 PATCHES DE SEGURANÇA

### PATCH 1: RATE LIMITING
**Severidade:** 🔴 CRÍTICA  
**Tempo Estimado:** 15 minutos  
**Arquivo:** `app/Http/Controllers/InspectionController.php`

**Checklist:**
- [ ] Abrir `SECURITY_PATCHES.md` - Seção "Patch 1"
- [ ] Copiar código do Patch 1
- [ ] Adicionar em `store()` method
- [ ] Testar em localhost (exceder 10 tentativas)
- [ ] Verificar mensagem de erro
- [ ] Commit: `git commit -m "feat: adiciona rate limiting em inspeções"`
- [ ] Push: `git push origin main`

**Verificação:**
```bash
# Testar localmente
curl http://localhost:8000/vistoria/nova -X POST # repitir 11x
# Deve mostrar: "Você excedeu o limite..."
```

---

### PATCH 2: PROTEÇÃO DE UPLOADS
**Severidade:** 🔴 CRÍTICA  
**Tempo Estimado:** 30 minutos  
**Arquivo:** `routes/web.php`

**Checklist:**
- [ ] Abrir `SECURITY_PATCHES.md` - Seção "Patch 2"
- [ ] Copiar código da rota de proteção
- [ ] Adicionar em `routes/web.php`
- [ ] Criar novo método em InspectionController
- [ ] Testar acesso como cliente (próprio)
- [ ] Testar acesso como outro cliente (403)
- [ ] Testar acesso como admin (permitido)
- [ ] Commit: `git commit -m "feat: protege acesso a uploads"`
- [ ] Push: `git push origin main`

**Verificação:**
```bash
# Cliente próprio - OK
http://localhost:8000/inspection/1/photo/frente.jpg

# Cliente diferente - 403
# Admin - OK
```

---

### PATCH 3: SOFT DELETE
**Severidade:** 🟡 ALTA  
**Tempo Estimado:** 1 hora  
**Arquivo:** `app/Models/Inspection.php`

**Checklist:**
- [ ] Abrir `SECURITY_PATCHES.md` - Seção "Patch 3"
- [ ] Criar migration: `php artisan make:migration add_soft_delete_to_inspections`
- [ ] Adicionar coluna `deleted_at`: `$table->softDeletes();`
- [ ] Atualizar Model Inspection
- [ ] Adicionar trait `use SoftDeletes;`
- [ ] Executar migration: `php artisan migrate`
- [ ] Testar delete: `Inspection::find(1)->delete()`
- [ ] Verificar: `Inspection::withTrashed()->count()`
- [ ] Commit: `git commit -m "feat: adiciona soft delete em inspeções"`
- [ ] Push: `git push origin main`

**Verificação:**
```php
// Executar em tinker
php artisan tinker
>>> $i = Inspection::find(1);
>>> $i->delete();
>>> Inspection::count(); // deve diminuir
>>> Inspection::withTrashed()->count(); // mesmo valor
```

---

### PATCH 4: TRATAMENTO DE EXCEÇÕES
**Severidade:** 🟡 ALTA  
**Tempo Estimado:** 45 minutos  
**Arquivo:** `app/Http/Controllers/InspectionController.php`

**Checklist:**
- [ ] Abrir `SECURITY_PATCHES.md` - Seção "Patch 4"
- [ ] Copiar estrutura de try-catch
- [ ] Adicionar imports de exceção
- [ ] Substituir catch genérico
- [ ] Adicionar logging estruturado
- [ ] Testar com erro de validação (ValidationException)
- [ ] Testar com erro de banco (QueryException)
- [ ] Testar com erro desconhecido (Exception)
- [ ] Commit: `git commit -m "fix: melhora tratamento de exceções"`
- [ ] Push: `git push origin main`

**Verificação:**
```php
// Forçar erros no browser
// 1. Validação: submeter sem fotos → ValidationException
// 2. Query: desconectar BD → QueryException
// 3. Genérico: forçar erro → Exception
```

---

### PATCH 5: VALIDAÇÃO DE UPLOAD TOTAL
**Severidade:** 🟡 ALTA  
**Tempo Estimado:** 15 minutos  
**Arquivo:** `app/Http/Controllers/InspectionController.php`

**Checklist:**
- [ ] Abrir `SECURITY_PATCHES.md` - Seção "Patch 5"
- [ ] Copiar nova validação (reduzir para 3.1MB)
- [ ] Substituir no método `store()`
- [ ] Nota: Total = 10 fotos × 3.1MB = 31MB
- [ ] Testar upload dentro do limite (OK)
- [ ] Testar upload acima do limite (erro)
- [ ] Commit: `git commit -m "fix: limita tamanho total de upload para 30MB"`
- [ ] Push: `git push origin main`

---

### PATCH 6: CACHE DE DASHBOARD
**Severidade:** 🟢 MÉDIA  
**Tempo Estimado:** 30 minutos  
**Arquivo:** `app/Http/Controllers/AdminController.php`

**Checklist:**
- [ ] Abrir `SECURITY_PATCHES.md` - Seção "Patch 6"
- [ ] Adicionar imports de Cache
- [ ] Envolver lógica em `Cache::remember()`
- [ ] Definir TTL = 3600 (1 hora)
- [ ] Testar primeira carga (lenta)
- [ ] Testar segunda carga (rápida - cache)
- [ ] Testar purga: `Cache::forget(key)`
- [ ] Commit: `git commit -m "perf: adiciona cache em dashboard admin"`
- [ ] Push: `git push origin main`

**Verificação:**
```bash
# Purgar cache quando necessário
php artisan cache:clear

# Ou em Controller
Cache::forget('admin_dashboard_' . Auth::id());
```

---

### PATCH 7: AUDIT TRAIL
**Severidade:** 🟢 MÉDIA  
**Tempo Estimado:** 2 horas  
**Arquivo:** Múltiplos

**Checklist:**
- [ ] Abrir `SECURITY_PATCHES.md` - Seção "Patch 7"
- [ ] Criar Model: `php artisan make:model AuditLog -m`
- [ ] Adicionar fields na migration
- [ ] Adicionar `booted()` em Inspection.php
- [ ] Testrar: `Inspection::find(1)->update(['status' => 'approved'])`
- [ ] Verificar: `AuditLog::where('model_id', 1)->get()`
- [ ] Commit: `git commit -m "feat: adiciona audit trail para inspeções"`
- [ ] Push: `git push origin main`

---

## 📊 TIMELINE DE IMPLEMENTAÇÃO

```
Dia 1 (2-3 horas):
├── Patch 1: Rate Limiting (15 min)
├── Patch 2: Proteção de Upload (30 min)
├── Patch 5: Validação Total (15 min)
└── Testes gerais (1 hora)

Dia 2 (2-3 horas):
├── Patch 3: Soft Delete (1 hora)
├── Patch 4: Tratamento de Erro (45 min)
└── Testes gerais (1 hora)

Dia 3 (2-3 horas):
├── Patch 6: Cache (30 min)
├── Patch 7: Audit Trail (2 horas)
└── Testes finais (30 min)

Total Estimado: 6-9 horas
```

---

## 🧪 TESTES RECOMENDADOS

### Teste 1: Rate Limiting
```bash
# Deve falhar na 11ª tentativa
for i in {1..15}; do
  curl -X POST http://localhost:8000/vistoria/nova
done
```

### Teste 2: Proteção de Upload
```php
// Cliente A tenta acessar foto de Cliente B
// Deve retornar 403 Forbidden
```

### Teste 3: Soft Delete
```php
$inspection = Inspection::first();
$inspection->delete();
assert(Inspection::count() == $original_count - 1);
assert(Inspection::withTrashed()->count() == $original_count);
```

### Teste 4: Cache
```php
// Primeira carga mede tempo (lenta)
// Segunda carga é mais rápida
// Após Cache::forget(), primeira carga novamente lenta
```

---

## ⚠️ POSSÍVEIS PROBLEMAS

### Problema: Rate Limit Muito Rigoroso
**Solução:** Aumentar para 20 em `$rateLimiter->tooManyAttempts()`

### Problema: Cache Desatualizado
**Solução:** Adicionar `cache()->forget()` em métodos que modificam dados

### Problema: Soft Delete Quebra Queries
**Solução:** Usar `withTrashed()` se necessário incluir deletados

### Problema: Audit Trail muito Lento
**Solução:** Usar filas: `dispatch(new LogAudit())->delay(now()->addSeconds(5))`

---

## ✅ VERIFICAÇÃO FINAL

Após implementar todos os patches:

```bash
# 1. Todos os commits criados
git log --oneline | head -7

# 2. Todos os patches subidos
git push origin main

# 3. Testes passando
php artisan test

# 4. Sem erros no production log
tail -n 50 storage/logs/laravel.log

# 5. Documentação atualizada
git status # deve estar limpo
```

---

## 📞 SUPORTE E DÚVIDAS

**Dúvida sobre implementação?**
→ Consulte `SECURITY_PATCHES.md` novamente

**Erro ao implementar?**
→ Confira a seção "Possíveis Problemas" acima

**Não entendeu o patch?**
→ Leia a seção correspondente em `REVISAO_COMPLETA.md`

---

## 🎓 LIÇÕES IMPORTANTES

1. **Sempre testes depois de cada patch**
2. **Um patch por commit**
3. **Mensagens de commit descritivas**
4. **Documentar mudanças em README.md**
5. **Fazer backup antes de deploy em produção**

---

## 📈 PRÓXIMAS FASES

Após completar todos os 7 patches:

- [ ] Criar testes unitários para cada patch
- [ ] Fazer teste de carga com 1000+ inspeções
- [ ] Deploy em staging
- [ ] Teste de segurança com OWASP ZAP
- [ ] Deploy em produção
- [ ] Monitoramento com Sentry
- [ ] Análise de performance

---

**Versão:** 1.0  
**Status:** ✅ Pronto para uso  
**Atualizado em:** 3 de dezembro de 2025

*Para dúvidas, consulte os documentos de referência no repositório.*
