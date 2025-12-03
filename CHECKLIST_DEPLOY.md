# ✅ Checklist de Deploy no HostGator

## 🎯 **Resumo Rápido**
Este sistema Laravel precisa ser configurado com uma estrutura específica no HostGator.

## 📋 **Checklist Passo a Passo**

### **Preparação Local:**
- [x] Executar `chmod +x deploy.sh && ./deploy.sh` ✅ **CONCLUÍDO**
- [x] Configurar `.env.hostgator` com suas credenciais ✅ **CONCLUÍDO**
- [ ] Fazer backup do projeto

### **No HostGator cPanel:**
- [ ] Criar banco de dados MySQL ✅ **Configurado**: `sist5700_vistoria`
- [ ] Usuário: `vistoriador` | Senha: `ycjo0-qezwyd-Wegcex` ✅
- [ ] Criar conta de email (ex: contato@grupoautocredcar.com.br)
- [ ] Verificar se PHP 8.1+ está ativo

### **Upload de Arquivos:**
- [x] Criar pasta `sistema-vistoria` em `/home/sist5700/` (FORA do grupoautocredcar.com.br) ✅ **CONCLUÍDO**
- [x] Upload todos os arquivos EXCETO pasta `public` para `/home/sist5700/sistema-vistoria/` ✅ **CONCLUÍDO**
- [x] Upload conteúdo da pasta `public` para `/home/sist5700/grupoautocredcar.com.br/vistoria/` ✅ **CONCLUÍDO**
- [x] Renomear `.env.hostgator` para `.env` em `/home/sist5700/sistema-vistoria/.env` ✅ **CONCLUÍDO**

### **Configurações:**
- [x] Editar `/home/sist5700/grupoautocredcar.com.br/vistoria/index.php` (ajustar caminhos) ✅ **CONCLUÍDO**
- [x] Copiar `.htaccess.hostgator` para `/home/sist5700/grupoautocredcar.com.br/vistoria/.htaccess` ✅ **CONCLUÍDO**
- [x] Configurar permissões (755 geral, 775 storage) ✅ **CONCLUÍDO**
- [x] Configurar `.env` com dados do banco e domínio: `APP_URL=https://grupoautocredcar.com.br/vistoria` ✅ **SQLite CONFIGURADO**

### **Banco de Dados:**
- [x] Executar migrações: `php artisan migrate --force` ✅ **CONCLUÍDO via SQLite**
- [x] Criar usuário admin (opcional): `php artisan db:seed` ✅ **CONCLUÍDO via SQLite**

### **Testes:**
- [x] Upload `test.php` para `/home/sist5700/grupoautocredcar.com.br/vistoria/` ✅ **CONCLUÍDO**
- [x] Acessar `https://grupoautocredcar.com.br/vistoria/test.php` ✅ **CONCLUÍDO**
- [x] Verificar se todos os ✅ estão OK ✅ **CONCLUÍDO**
- [ ] Deletar `test.php` após verificação

### **Verificação Final:**
- [x] Acessar: `https://grupoautocredcar.com.br/vistoria/` ✅ **FUNCIONANDO** (página welcome)
- [ ] Fazer login/registro 🔄 **Configurando SQLite...**
- [ ] Testar envio de vistoria
- [ ] Testar painel admin
- [ ] Verificar emails de notificação

## 🚀 **URLs Importantes**
- **Site**: https://grupoautocredcar.com.br/vistoria/
- **Login**: https://grupoautocredcar.com.br/vistoria/login
- **Admin**: https://grupoautocredcar.com.br/vistoria/admin/dashboard
- **Registrar**: https://grupoautocredcar.com.br/vistoria/register

## 🆘 **Problemas Comuns**

### **Error 500:**
1. Verificar permissões das pastas
2. Verificar .env (especialmente APP_KEY)
3. Conferir logs em `sistema-vistoria/storage/logs/`

### **CSS/JS não carrega:**
1. Conferir se arquivos estão em `/home/sist5700/grupoautocredcar.com.br/vistoria/`
2. Verificar APP_URL no .env: `APP_URL=https://grupoautocredcar.com.br/vistoria`
3. Limpar cache: `php artisan cache:clear`

### **Banco não conecta:**
1. Verificar credenciais no .env
2. Testar conexão no phpMyAdmin
3. Verificar se banco existe no cPanel

## 💡 **Dicas Importantes**
- Sempre use HTTPS em produção
- Mantenha backups regulares
- Monitore os logs em `storage/logs/`
- Configure SSL/TLS no HostGator
- Use senhas fortes para banco e admin

## 📞 **Suporte**
- **Laravel**: https://laravel.com/docs/11.x
- **HostGator**: Central de Ajuda HostGator
- **Logs**: `sistema-vistoria/storage/logs/laravel.log`
