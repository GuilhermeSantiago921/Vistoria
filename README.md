# 🚗 Sistema de Vistoria Veicular

Sistema completo de gerenciamento de vistorias veiculares com upload de fotos, análise técnica, integração com base de dados externa e geração de relatórios em PDF.

## ✨ Características Principais

- 📸 **Upload de 10 fotos** por vistoria
- 💳 **Sistema de créditos** para controle de uso
- 👥 **3 níveis de acesso**: Administrador, Analista e Cliente
- 📊 **Painel administrativo** completo
- ✅ **Checklist técnico** detalhado
- 🔗 **Integração SQL Server** externa
- 📄 **Geração de PDF** com relatório completo
- 📧 **Notificações por e-mail** automáticas
- 📱 **Interface responsiva**
- 🔒 **Segurança** robusta

## 📋 Requisitos

- **SO**: Ubuntu 20.04+, Debian 11+ ou Rocky Linux 8/9
- **PHP**: 8.2+
- **MySQL/MariaDB**: 8.0+ / 10.3+ (ou SQLite)
- **Node.js**: 18.x+
- **RAM**: 2GB mínimo
- **Disco**: 20GB mínimo

## 🚀 Instalação Rápida

### Ubuntu/Debian

```bash
git clone https://github.com/GuilhermeSantiago921/vistoria.git
cd vistoria
sudo bash install.sh
```

### Rocky Linux

```bash
git clone https://github.com/GuilhermeSantiago921/vistoria.git
cd vistoria
sudo bash install-rocky-linux.sh
```

O instalador irá configurar TUDO automaticamente! ✨

## 💻 Desenvolvimento Local

```bash
# Servidor otimizado
./start-dev.sh

# Ou com Docker
docker-compose up -d
```

## 📸 Fotos Necessárias

1. Frente do Veículo
2. Traseira do Veículo
3. Lateral Direita
4. Lateral Esquerda
5. Vidro Lateral Direita (Gravação)
6. Vidro Lateral Esquerda (Gravação)
7. Gravação do Chassi
8. Etiqueta de Identificação (ETA)
9. Hodômetro
10. Motor

## 👥 Níveis de Acesso

| Tipo | Permissões |
|------|------------|
| **Admin** | Gerenciar usuários, atribuir créditos, todas as vistorias |
| **Analista** | Analisar vistorias, aprovar/reprovar, gerar relatórios |
| **Cliente** | Solicitar vistorias, upload de fotos, acompanhar status |

## 📚 Documentação

- [`INSTALL_LINUX.md`](INSTALL_LINUX.md) - Instalação Ubuntu/Debian
- [`INSTALL_ROCKY_LINUX.md`](INSTALL_ROCKY_LINUX.md) - Instalação Rocky Linux
- [`README_DEV.md`](README_DEV.md) - Desenvolvimento
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Problemas comuns

## 🔧 Comandos Úteis

```bash
# Limpar cache
php artisan cache:clear
php artisan config:clear

# Ver logs
tail -f storage/logs/laravel.log

# Criar admin
php artisan tinker
>>> User::create(['name' => 'Admin', 'email' => 'admin@test.com', 'password' => bcrypt('senha123'), 'role' => 'admin', 'inspection_credits' => 999]);
```

## 🛡️ Segurança

✅ Senhas bcrypt  
✅ Proteção CSRF  
✅ Validação de uploads  
✅ SQL injection prevention  
✅ XSS protection  
✅ Rate limiting  

## 💾 Backup Automático

Configurado automaticamente para rodar diariamente às 2h em `/backups/vistoria/`

## 📞 Suporte

- 📧 guilhermesantiago921@gmail.com
- 💬 [GitHub Issues](https://github.com/GuilhermeSantiago921/vistoria/issues)

## 📝 Licença

[Adicione informações de licença]

---

**Desenvolvido com ❤️ para facilitar a gestão de vistorias veiculares**

⭐ Se este projeto foi útil, dê uma estrela no GitHub!
