# 🚀 INSTALAÇÃO RÁPIDA - Sistema de Vistoria

## ⚡ Instalação com Um Comando (SUPER RÁPIDO)

### Ubuntu / Debian

**Opção 1: Download direto (mais rápido)**
```bash
wget -O - https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install.sh | sudo bash
```

**Opção 2: Clone do repositório**
```bash
git clone https://github.com/GuilhermeSantiago921/Vistoria.git
cd Vistoria
sudo bash install.sh
```

**Opção 3: Download e executar separado**
```bash
wget https://github.com/GuilhermeSantiago921/Vistoria/archive/main.zip
unzip main.zip
cd Vistoria-main
sudo bash install.sh
```

### Rocky Linux / CentOS

**Opção 1: Download direto (mais rápido)**
```bash
wget -O - https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-rocky-linux.sh | sudo bash
```

**Opção 2: Clone do repositório**
```bash
git clone https://github.com/GuilhermeSantiago921/Vistoria.git
cd Vistoria
sudo bash install-rocky-linux.sh
```

**Opção 3: Download e executar separado**
```bash
wget https://github.com/GuilhermeSantiago921/Vistoria/archive/main.zip
unzip main.zip
cd Vistoria-main
sudo bash install-rocky-linux.sh
```

---

## 📝 O instalador vai perguntar:

1. **Domínio** (ex: vistoria.exemplo.com)
2. **Email do administrador**
3. **Senha do administrador**
4. **Instalar MySQL?** (S/n - padrão: SQLite)
5. **Instalar SSL?** (S/n - padrão: Sim)

---

## ⏱️ Tempo de instalação

- **Conexão rápida:** 10-15 minutos
- **Conexão média:** 20-30 minutos

---

## ✅ Após a instalação

O sistema estará disponível em:
- **HTTP:** `http://seu-dominio.com`
- **HTTPS:** `https://seu-dominio.com` (se SSL instalado)

**Login inicial:**
- Email: [o que você configurou]
- Senha: [a que você configurou]

---

## 🔧 Requisitos Mínimos

- Ubuntu 20.04+ / Debian 11+ / Rocky Linux 8+
- 2GB RAM
- 20GB disco
- Acesso root (sudo)

---

## 💻 Desenvolvimento Local (macOS/Linux)

```bash
git clone https://github.com/GuilhermeSantiago921/vistoria.git
cd vistoria
./start-dev.sh
```

Acesse: http://localhost:8000

---

## 📚 Documentação Completa

- `README.md` - Visão geral
- `INSTALL_LINUX.md` - Instalação manual Ubuntu/Debian
- `INSTALL_ROCKY_LINUX.md` - Instalação manual Rocky Linux
- `TROUBLESHOOTING.md` - Problemas comuns

---

## 🆘 Problemas?

### Erro durante instalação

```bash
# Ver logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f storage/logs/laravel.log
```

### Reinstalar

```bash
cd vistoria
sudo bash install.sh  # Executar novamente
```

---

## 📞 Suporte

- Email: guilhermesantiago921@gmail.com
- GitHub: https://github.com/GuilhermeSantiago921/vistoria/issues

---

**Instalação super simples! Basta executar o script e responder algumas perguntas.** 🎉
