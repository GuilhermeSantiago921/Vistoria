# 📦 Lista de Arquivos para Upload - Fix BIN Agregados

## ✅ Arquivos NOVOS (Criar no servidor)

### public/test-agregados.php
**Caminho:** `/home1/sist5700/grupoautocredcar.com.br/vistoria/public/test-agregados.php`
**Função:** Testa conexão SQL Server e extensões PHP
**Uso:** https://grupoautocredcar.com.br/test-agregados.php
**Status:** ⚠️ Temporário - APAGAR após teste

### public/clear-cache-agregados.php
**Caminho:** `/home1/sist5700/grupoautocredcar.com.br/vistoria/public/clear-cache-agregados.php`
**Função:** Limpa cache do Laravel via web
**Uso:** https://grupoautocredcar.com.br/clear-cache-agregados.php
**Status:** ⚠️ Temporário - APAGAR após uso

### public/get-server-ip.php
**Caminho:** `/home1/sist5700/grupoautocredcar.com.br/vistoria/public/get-server-ip.php`
**Função:** Mostra IP do servidor para liberar no firewall
**Uso:** https://grupoautocredcar.com.br/get-server-ip.php
**Status:** ⚠️ Temporário - APAGAR após obter IP

---

## ✅ Arquivos ATUALIZADOS (Substituir no servidor)

### app/Http/Controllers/InspectionController.php
**Caminho:** `/home1/sist5700/grupoautocredcar.com.br/vistoria/app/Http/Controllers/InspectionController.php`
**Mudanças:**
- Método `pullAggregates()` linha 341
- Logging detalhado adicionado
- Tratamento de erros melhorado
- Teste de conexão antes da query
**Status:** ✅ Permanente

### .env
**Caminho:** `/home1/sist5700/grupoautocredcar.com.br/vistoria/.env`
**Mudanças:** Adicionar estas 2 linhas após `DB_AGREGADOS_PASSWORD`:
```env
DB_AGREGADOS_ENCRYPT=no
DB_AGREGADOS_TRUST_SERVER_CERTIFICATE=yes
```
**Status:** ✅ Permanente

---

## 📋 Procedimento de Upload

### Via cPanel File Manager

1. **Login no cPanel**
   - URL: https://cpanel.hostgator.com.br
   - Usuário: sist5700
   - Senha: [sua senha]

2. **Navegar até o diretório**
   ```
   /home1/sist5700/grupoautocredcar.com.br/vistoria/
   ```

3. **Upload dos arquivos NOVOS**
   - Ir para: `public/`
   - Clicar em **Upload**
   - Selecionar:
     - `test-agregados.php`
     - `clear-cache-agregados.php`
     - `get-server-ip.php`

4. **Substituir arquivo atualizado**
   - Ir para: `app/Http/Controllers/`
   - Fazer **backup** do `InspectionController.php` atual:
     - Renomear para: `InspectionController.php.backup`
   - Upload do novo `InspectionController.php`

5. **Editar .env**
   - Voltar para: `/home1/sist5700/grupoautocredcar.com.br/vistoria/`
   - Clicar com botão direito em `.env` → **Edit**
   - Localizar a linha `DB_AGREGADOS_PASSWORD=Prime@2024%23`
   - Adicionar logo abaixo:
     ```env
     DB_AGREGADOS_ENCRYPT=no
     DB_AGREGADOS_TRUST_SERVER_CERTIFICATE=yes
     ```
   - Salvar (Ctrl+S)

---

## 🔄 Sequência de Testes

Execute nesta ordem:

1. **Testar conexão**
   ```
   https://grupoautocredcar.com.br/test-agregados.php
   ```
   - ✅ Esperado: "Conexão OK"
   - ❌ Se falhar: Ver `SOLUCAO_ERRO_AGREGADOS.md`

2. **Limpar cache**
   ```
   https://grupoautocredcar.com.br/clear-cache-agregados.php
   ```
   - ✅ Esperado: "Cache limpo com sucesso"

3. **Testar botão no sistema**
   - Login como analista
   - Abrir uma vistoria
   - Clicar em "Puxar/Atualizar Dados da BIN Agregados"
   - ✅ Esperado: Mensagem de sucesso com Chassi e Motor

4. **Verificar logs** (se houver erro)
   ```
   storage/logs/laravel.log
   ```
   - Procurar por: "pullAggregates"

---

## 🧹 Limpeza Pós-Deploy

Após TODOS os testes passarem, apagar:

```
✅ public/test-agregados.php
✅ public/clear-cache-agregados.php
✅ public/get-server-ip.php
✅ app/Http/Controllers/InspectionController.php.backup (se criou)
```

**NÃO APAGUE:**
- `.env` (permanente)
- `InspectionController.php` (permanente)

---

## 📊 Resumo

| Arquivo | Ação | Status | Apagar depois? |
|---------|------|--------|----------------|
| test-agregados.php | Upload | Novo | ✅ SIM |
| clear-cache-agregados.php | Upload | Novo | ✅ SIM |
| get-server-ip.php | Upload | Novo | ✅ SIM |
| InspectionController.php | Substituir | Atualizado | ❌ NÃO |
| .env | Editar | Atualizado | ❌ NÃO |

---

## ⏱️ Tempo Estimado

- **Upload dos arquivos:** 5 minutos
- **Edição do .env:** 2 minutos
- **Testes:** 5-10 minutos
- **Limpeza:** 2 minutos
- **TOTAL:** 15-20 minutos

---

## 🆘 Problemas Comuns

### "Arquivo não encontrado" ao acessar test-agregados.php
- Verificar se upload foi feito em `public/` (não na raiz)
- Caminho correto: `vistoria/public/test-agregados.php`

### "Permission denied" ao editar .env
- Verificar permissões do arquivo (deve ser 644)
- Se necessário, usar Terminal SSH

### Cache não limpa
- Usar Terminal SSH:
  ```bash
  cd /home1/sist5700/grupoautocredcar.com.br/vistoria
  php artisan config:clear
  php artisan cache:clear
  ```

### Botão ainda não funciona
- Verificar logs: `storage/logs/laravel.log`
- Executar novamente: `test-agregados.php`
- Se teste passa mas botão falha = problema de cache

---

## 📞 Contatos

**Suporte HostGator:**
- Chat: https://suporte.hostgator.com.br
- Telefone: 0800 580 1334

**Administrador SQL Server:**
- Servidor: 189.113.13.114
- Contato: [informar se necessário liberar IP]

---

## ✅ Checklist Final

- [ ] Backup do `InspectionController.php` atual
- [ ] Upload dos 3 arquivos novos em `public/`
- [ ] Upload do `InspectionController.php` atualizado
- [ ] Editado `.env` com 2 linhas novas
- [ ] Executado `test-agregados.php` - passou
- [ ] Executado `clear-cache-agregados.php` - passou
- [ ] Testado botão no sistema - funcionou
- [ ] Apagados os 3 arquivos temporários
- [ ] Verificado que vistoria mostra Chassi e Motor atualizados

---

**Pronto! Sistema funcionando! 🚀**
