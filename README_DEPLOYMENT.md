# 📖 Índice de Documentação de Deployment - Sistema de Vistoria

## 🎯 Comece Aqui

### Para Iniciantes
👉 **[COMECE_AQUI_DEPLOY.md](COMECE_AQUI_DEPLOY.md)** ← LEIA PRIMEIRO!
- Instruções passo a passo
- O que você precisa fazer
- Checklist pré-deployment
- Troubleshooting básico

---

## 📚 Documentação Completa

### Guia Rápido (Recomendado para 90% dos casos)
📄 **[DEPLOY_RAPIDO.md](DEPLOY_RAPIDO.md)**
- Deploy em 5 minutos
- Comandos prontos para copiar e colar
- Configuração essencial
- Monitoramento básico

### Guia Completo (Para quem quer aprofundar)
📄 **[DEPLOY_DOCKER.md](DEPLOY_DOCKER.md)**
- Explicação detalhada de cada passo
- Opções de customização
- Segurança para produção
- Backup e manutenção
- Troubleshooting avançado

### Fluxo Visual (Para visualizar arquitetura)
📄 **[FLUXO_DEPLOYMENT.md](FLUXO_DEPLOYMENT.md)**
- Diagrama da arquitetura
- Timeline de deployment
- Fluxo de dados
- Decisões importantes
- Comandos de gerenciamento

### Checklist Visual (Última verificação antes de começar)
📄 **[RESUMO_DEPLOYMENT.txt](RESUMO_DEPLOYMENT.txt)**
- Checklist em formato visual
- Arquivos que serão gerados
- Próximos passos
- Informações importantes

---

## 🔧 Scripts de Automation

### Script de Exportação (EXECUTE NO SEU PC)
```bash
./export-docker-images.sh
```
**Localizado em:** `/Users/guilherme/Documents/bkp72vistoria/vistoria/`

**O que faz:**
- Salva todas as imagens Docker
- Compacta o projeto
- Gera script de transferência
- Exibe resumo dos arquivos

**Tempo:** ~5-10 minutos

---

### Script de Transferência (EXECUTE NO SEU PC)
```bash
./transfer-to-server.sh root@seu-servidor-ip 22
```

**O que faz:**
- Transfere pacote do projeto
- Transfere script de instalação
- Transfere imagens Docker
- Confirma sucesso

**Tempo:** ~10-30 minutos (depende da internet)

---

### Script de Instalação (EXECUTE NO SERVIDOR)
```bash
sudo bash /tmp/install-docker-server.sh
```

**O que faz:**
- Instala Docker
- Instala Docker Compose
- Carrega imagens
- Descompacta projeto
- Configura ambiente
- Inicia containers
- Executa migrações

**Tempo:** ~10-15 minutos

**Totalmente automático!**

---

## 📊 Matriz de Decisão

### Qual documentação ler?

| Perfil | Tempo | Documentação |
|--------|-------|--------------|
| **Tenho pressa** | 5 min | [DEPLOY_RAPIDO.md](DEPLOY_RAPIDO.md) |
| **Sou iniciante** | 15 min | [COMECE_AQUI_DEPLOY.md](COMECE_AQUI_DEPLOY.md) |
| **Quero entender tudo** | 30 min | [DEPLOY_DOCKER.md](DEPLOY_DOCKER.md) |
| **Visual/Diagrama** | 10 min | [FLUXO_DEPLOYMENT.md](FLUXO_DEPLOYMENT.md) |
| **Checklist antes** | 5 min | [RESUMO_DEPLOYMENT.txt](RESUMO_DEPLOYMENT.txt) |

---

## 🚀 Quick Start (3 Passos)

### 1. Local
```bash
cd ~/Documents/bkp72vistoria/vistoria
./export-docker-images.sh
```

### 2. Transferência
```bash
./transfer-to-server.sh root@seu-servidor-ip 22
```

### 3. Servidor
```bash
ssh root@seu-servidor-ip
sudo bash /tmp/install-docker-server.sh
```

**Pronto! 🎉**

---

## 📍 Fluxo de Leitura Recomendado

```
1. RESUMO_DEPLOYMENT.txt     (5 min)  - Entender o escopo
   ↓
2. COMECE_AQUI_DEPLOY.md     (10 min) - Instruções iniciais
   ↓
3. DEPLOY_RAPIDO.md          (5 min)  - Preparar comandos
   ↓
4. FLUXO_DEPLOYMENT.md       (5 min)  - Visualizar arquitetura
   ↓
5. DEPLOY_DOCKER.md          (15 min) - Leitura opcional (completa)
```

---

## ✅ Verificação Antes de Começar

### No seu computador
- [ ] Sistema de Vistoria rodando (http://localhost:8000)
- [ ] Docker instalado (`docker --version`)
- [ ] Docker Compose funcionando (`docker-compose --version`)
- [ ] Acesso SSH ao servidor pronto
- [ ] IP/Domínio do servidor conhecido

### Servidor Ubuntu
- [ ] Ubuntu 20.04+ ou Debian 11+
- [ ] Mínimo 2GB RAM
- [ ] 20GB espaço em disco
- [ ] Conexão SSH funcionando
- [ ] Acesso root ou sudo

---

## 🔐 Credenciais Padrão

```
MySQL:
  Usuário: vistoria
  Senha: vistoria_pass
  Host: vistoria-mysql
  Banco: vistoria

phpMyAdmin:
  Usuário: vistoria
  Senha: vistoria_pass
```

⚠️ **IMPORTANTE:** Altere estas senhas em produção!

---

## 🌐 Acessar Após Deploy

```
Aplicação:       http://seu-servidor-ip:8000
phpMyAdmin:      http://seu-servidor-ip:8080
Redis Commander: http://seu-servidor-ip:8081
MailHog:         http://seu-servidor-ip:8025
```

---

## 📦 O Que Será Gerado

### Arquivos Locais (após export-docker-images.sh)
- `vistoria-docker-complete.tar.gz` (~500MB)
- `images/` (~3-5GB com 6 imagens Docker)
- `transfer-to-server.sh` (script)

### No Servidor (após install-docker-server.sh)
- `/var/www/vistoria/` (projeto instalado)
- `/data/vistoria/` (volumes de dados)
- 6 containers Docker rodando
- Banco de dados MySQL pronto
- Todas as migrações executadas

---

## 🆘 Precisa de Ajuda?

### Erro durante exportação?
👉 [DEPLOY_DOCKER.md - Troubleshooting Local](DEPLOY_DOCKER.md#troubleshooting)

### Erro durante transferência?
👉 [DEPLOY_RAPIDO.md - Transferência Manual](DEPLOY_RAPIDO.md#opção-b-transferência-manual)

### Erro durante instalação?
👉 [DEPLOY_DOCKER.md - Troubleshooting Servidor](DEPLOY_DOCKER.md#troubleshooting)

### Container não inicia?
👉 Ver logs: `docker-compose logs app`

---

## 🔄 Atualizar/Redeployed

Se precisar fazer deploy novamente:

```bash
# Local
./export-docker-images.sh
./transfer-to-server.sh root@seu-servidor-ip 22

# Servidor
docker-compose down
# (remover pasta ou git pull)
sudo bash /tmp/install-docker-server.sh
```

---

## 📊 Próximas Etapas Após Instalação

1. **Segurança** (1º dia)
   - [ ] Alterar senhas do .env
   - [ ] Configurar firewall

2. **SSL/Domínio** (2º dia)
   - [ ] Configurar Let's Encrypt
   - [ ] Setup Nginx reverso proxy

3. **Backups** (1ª semana)
   - [ ] Agendar backups automáticos
   - [ ] Testar restauração

4. **Monitoramento** (1ª semana)
   - [ ] Configurar alertas
   - [ ] Monitorar performance

---

## 📞 Contato e Suporte

Para dúvidas técnicas:
1. Consulte a documentação (links acima)
2. Verifique os logs: `docker-compose logs`
3. Consulte [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📄 Documento Original

Este índice foi criado em **18 de fevereiro de 2026** para o Sistema de Vistoria Veicular.

**Status:** ✅ Pronto para Production Deployment

---

**Próximo passo:** Leia [COMECE_AQUI_DEPLOY.md](COMECE_AQUI_DEPLOY.md) 🚀
