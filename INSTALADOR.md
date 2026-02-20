# 🚗 Sistema de Vistoria Veicular — Guia de Instalação

Instalador automático e completo para Ubuntu Server 22.04/24.04 LTS

---

## 📋 Pré-requisitos

- **Ubuntu Server** 22.04 LTS ou 24.04 LTS
- **RAM mínima**: 512 MB (recomendado: 2 GB+)
- **Disco**: 5 GB livres
- **Conexão de internet** ativa
- **Acesso root** ou `sudo`

---

## 🚀 Como Instalar

### Opção 1: Executar o Script Diretamente

Se você está num servidor Ubuntu novo:

```bash
sudo bash instalar.sh
```

### Opção 2: Baixar e Executar do GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/instalar.sh | sudo bash
```

### Opção 3: Clonar o Repositório Primeiro

```bash
git clone https://github.com/GuilhermeSantiago921/Vistoria.git
cd Vistoria
sudo bash instalar.sh
```

---

## 📝 Configuração Interativa

O instalador fará as seguintes perguntas:

### 1️⃣ URL do Sistema
```
Exemplos: http://meusite.com.br  |  http://192.168.1.100
```
- Se você tiver um domínio, use: `https://seu-dominio.com.br`
- Se ainda não tiver, use o IP do servidor: `http://seu-ip`
- Pode ser alterado depois em `.env`

### 2️⃣ Banco de Dados MySQL
```
Senha para o usuário ROOT do MySQL
Confirme a senha root

Nome do banco de dados [vistoria]
Nome do usuário do banco [vistoria_user]

Senha do usuário do banco
Confirme a senha do banco
```

**Dicas:**
- O ROOT do MySQL receberá uma senha forte
- O usuário `vistoria_user` receberá permissão total no banco `vistoria`
- As credenciais são salvas em `/root/.vistoria_mysql_credentials` (modo leitura restrita)

### 3️⃣ Administrador
```
Nome completo do administrador [Administrador]
E-mail do administrador [admin@vistoria.com.br]

Senha do administrador (mínimo 8 caracteres)
Confirme a senha do administrador
```

### 4️⃣ SSL/HTTPS
```
Instalar SSL com Let's Encrypt/Certbot? [S/n]
```

- **[S]** — Instala SSL automático (exige domínio válido com DNS apontado)
- **[n]** — Pula SSL (pode instalar depois)

---

## ⚙️ O que o Instalador Faz

| Passo | Ação |
|-------|------|
| 1 | Atualiza sistema e instala dependências básicas |
| 2 | Instala **PHP 8.2** com extensões para Laravel |
| 3 | Instala **Composer** (gerenciador de pacotes PHP) |
| 4 | Instala **Node.js 20 LTS** e NPM |
| 5 | Instala e configura **Nginx** como servidor web |
| 6 | Instala e configura **MySQL 8** |
| 7 | Clona o repositório do GitHub |
| 8 | Gera arquivo `.env` com credenciais |
| 9 | Instala dependências PHP e JS via `composer` e `npm` |
| 10 | Compila assets (CSS/JavaScript) para produção |
| 11 | Cria banco de dados e tabelas (migrations) |
| 12 | Cria usuário administrador |
| 13 | Configura **Supervisor** para filas em background |
| 14 | Configura **Firewall UFW** (portas 22, 80, 443) |
| 15 | Instala **SSL com Let's Encrypt** (opcional) |
| 16 | Configura **Cron** para renovação de SSL e tarefas agendadas |

---

## ✅ Verificar Instalação

Após a conclusão, o instalador mostrará um **resumo com credenciais**. Guarde em local seguro!

### Arquivos Importantes

```
📁 Aplicação      : /var/www/vistoria
⚙️  Configuração   : /var/www/vistoria/.env
📋 Logs app       : /var/www/vistoria/storage/logs/laravel.log
🔧 Config Nginx   : /etc/nginx/sites-available/vistoria
📝 Log instalação : /tmp/vistoria-install-DATAHORA.log
📜 Credenciais BD : /root/.vistoria_mysql_credentials
```

### Testar a Instalação

```bash
# Verificar se Nginx está rodando
sudo systemctl status nginx

# Verificar se PHP-FPM está ativo
sudo systemctl status php8.2-fpm

# Verificar se MySQL está ativo
sudo systemctl status mysql

# Verificar workers de fila
sudo supervisorctl status
```

### Acessar o Sistema

1. **Abra o navegador** e vá para: `http://seu-dominio.com.br` (ou `http://seu-ip`)
2. **Faça login** com as credenciais de admin fornecidas
3. **Bem-vindo!** 🎉

---

## 🔧 Configurações Pós-Instalação

### 1. Configurar E-mail (SMTP)

Edite `/var/www/vistoria/.env` e procure por:

```bash
MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS="noreply@seu-dominio.com.br"
```

Se quiser usar Gmail, SendGrid ou outro serviço, altere estas variáveis e execute:

```bash
cd /var/www/vistoria
php artisan config:cache
```

### 2. Instalar SSL Depois (se não fez na instalação)

```bash
sudo certbot --nginx -d seu-dominio.com.br -d www.seu-dominio.com.br
```

### 3. Criar Backup do Banco

```bash
mysqldump -uroot -p vistoria > /backup/vistoria_$(date +%Y%m%d_%H%M%S).sql
```

### 4. Monitorar Performance

```bash
# Ver uso de RAM/CPU
htop

# Ver uso de disco
df -h

# Ver logs do Nginx
tail -f /var/log/nginx/error.log

# Ver logs da aplicação
tail -f /var/www/vistoria/storage/logs/laravel.log

# Ver status dos workers
sudo supervisorctl status
```

---

## 🐛 Solução de Problemas

### Erro: "Falha ao clonar repositório"
- Verifique conexão com internet
- Confirme se o repositório GitHub está acessível

### Erro: "Falha ao criar usuário administrador"
- Crie manualmente depois:
```bash
cd /var/www/vistoria
php artisan db:seed --class=Database\\Seeders\\AdminUserSeeder
```

### Erro: "Permissões insuficientes"
- Verifique se está executando com `sudo`

### Site mostra erro 502 Bad Gateway
- Reinicie PHP-FPM:
```bash
sudo systemctl restart php8.2-fpm
```

### MySQL não inicia
- Verifique permissões:
```bash
sudo chown -R mysql:mysql /var/lib/mysql
sudo systemctl restart mysql
```

### SSL não funciona após instalação
- Certifique-se que o **DNS** do domínio aponta para este servidor
- Aguarde propagação de DNS (pode levar até 24h)
- Tente novamente depois:
```bash
sudo certbot renew --dry-run
```

---

## 📞 Suporte

Para dúvidas ou problemas:

1. Consulte o **log completo** salvo em `/tmp/vistoria-install-DATAHORA.log`
2. Verifique os **logs de erro**:
   - `tail -f /var/www/vistoria/storage/logs/laravel.log`
   - `sudo tail -f /var/log/nginx/error.log`
3. Abra uma **issue** no GitHub: https://github.com/GuilhermeSantiago921/Vistoria/issues

---

## 🔐 Segurança

✅ **O instalador automaticamente:**
- Configura permissões corretas (www-data owns app)
- Ativa Firewall UFW (apenas portas 22, 80, 443)
- Usa senhas aleatórias fortes para MySQL
- Gera certificado SSL (Let's Encrypt)
- Desabilita directory listing
- Habilita OPcache do PHP

⚠️ **Você deve:**
- Manter o `.env` seguro (nunca versionar no Git)
- Alterar senhas padrão regularmente
- Fazer backup do banco de dados
- Manter Linux, PHP e dependências atualizados
- Revisar logs de segurança regularmente

---

## 📋 Estrutura do Projeto

```
/var/www/vistoria/
├── app/                 # Código da aplicação (Controllers, Models, etc.)
├── bootstrap/           # Bootstrap do Laravel
├── config/              # Configurações
├── database/
│   ├── migrations/      # Migrações SQL
│   └── seeders/         # Dados iniciais
├── public/              # Raiz do servidor web
├── resources/           # Views, CSS, JS
├── routes/              # Definições de rotas
├── storage/             # Uploads, cache, logs
├── tests/               # Testes automatizados
├── .env                 # Variáveis de ambiente (NUNCA versionar!)
├── .env.example         # Exemplo de .env
├── artisan              # CLI Laravel
└── composer.json        # Dependências PHP
```

---

## 🎯 Próximos Passos

1. ✅ Instalação concluída
2. 🌐 Aponte o DNS para este servidor
3. 📧 Configure e-mail em `.env`
4. 🔐 Considere instalar SSL
5. 📱 Comece a usar o sistema!

---

**Versão do Instalador**: 2.1  
**Última atualização**: Fevereiro 2026  
**Repositório**: https://github.com/GuilhermeSantiago921/Vistoria
