# 🚀 Guia de Desenvolvimento - Sistema de Vistoria

## ⚠️ Erro "Broken Pipe" - RESOLVIDO

Se você viu o erro:
```
Notice: file_put_contents(): Write of 72 bytes failed with errno=32 Broken pipe
```

**Não se preocupe!** Este é um problema conhecido do servidor de desenvolvimento PHP built-in.

## ✅ Solução Rápida

Use o script otimizado:

```bash
./start-dev.sh
```

Este script:
- ✅ Configura upload de até 50MB por foto
- ✅ Aumenta timeout para 300 segundos
- ✅ Otimiza buffer de memória
- ✅ Limpa cache automaticamente
- ✅ Verifica porta 8000
- ✅ Configura permissões

## 🎯 Alternativas Melhores

### Opção 1: Laravel Valet (⭐ RECOMENDADO para macOS)

```bash
# Instalar (uma vez)
composer global require laravel/valet
echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
valet install

# No diretório do projeto
valet link vistoria

# Acessar
open http://vistoria.test
```

**Vantagens:**
- ✅ Zero configuração após instalação
- ✅ URLs bonitas (.test)
- ✅ Certificado HTTPS automático
- ✅ Múltiplos projetos simultaneamente
- ✅ Performance excelente
- ✅ Sem erro "Broken pipe"

### Opção 2: Docker (Multiplataforma)

```bash
# Iniciar
docker-compose up -d

# Acessar
open http://localhost:8000

# Parar
docker-compose down
```

### Opção 3: Servidor Otimizado (Atual)

```bash
./start-dev.sh
```

## 🔧 Desenvolvimento

### Comandos Úteis

```bash
# Limpar cache
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Ver logs em tempo real
tail -f storage/logs/laravel.log

# Recompilar assets
npm run dev

# Executar testes
php artisan test

# Criar usuário admin
php artisan tinker
>>> User::create(['name' => 'Admin', 'email' => 'admin@test.com', 'password' => bcrypt('senha123'), 'role' => 'admin', 'inspection_credits' => 999]);
```

### Estrutura de Upload

As fotos são salvas em:
```
storage/app/public/inspections/{inspection_id}/
```

Para acessar via web:
```
public/storage/inspections/{inspection_id}/
```

### Credenciais de Teste

Banco de dados local (`.env`):
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vistoria
DB_USERNAME=root
DB_PASSWORD=
```

## 📝 Testando Upload de Fotos

1. Acesse: http://localhost:8000
2. Faça login
3. Vá em "Nova Vistoria"
4. Adicione as 10 fotos
5. Envie o formulário

Se aparecer o erro "Broken pipe" mas a vistoria for salva com sucesso, está funcionando! O erro é apenas um aviso do servidor de desenvolvimento.

## 🐛 Troubleshooting

### Erro: Porta 8000 em uso

```bash
# Encontrar processo
lsof -ti:8000

# Matar processo
lsof -ti:8000 | xargs kill -9

# Ou use o script que faz isso automaticamente
./start-dev.sh
```

### Erro: Permission denied

```bash
chmod -R 775 storage bootstrap/cache
```

### Erro: Storage link não existe

```bash
php artisan storage:link
```

### Upload não funciona

1. Verifique permissões:
```bash
ls -la storage/
```

2. Verifique logs:
```bash
tail -f storage/logs/laravel.log
```

3. Verifique configuração PHP:
```bash
php -i | grep upload_max_filesize
php -i | grep post_max_size
```

## 📊 Monitoramento

Ver logs em tempo real:

```bash
# Laravel
tail -f storage/logs/laravel.log

# Servidor PHP
# Os logs aparecem no terminal onde você executou ./start-dev.sh
```

## 🚀 Deploy para Produção

Quando estiver pronto para produção no Rocky Linux:

```bash
# No servidor
./install-rocky-linux.sh
```

Ou siga o guia manual: `INSTALL_ROCKY_LINUX.md`

## 💡 Dicas

1. **Use Laravel Valet** se estiver desenvolvendo regularmente no macOS
2. **Use Docker** se precisar de um ambiente idêntico à produção
3. **Use `start-dev.sh`** para testes rápidos
4. **Nunca use `php artisan serve` simples** para upload de arquivos grandes

## 📚 Documentos Relacionados

- `SOLUCAO_BROKEN_PIPE.md` - Detalhes técnicos do erro
- `INSTALL_ROCKY_LINUX.md` - Guia de instalação em produção
- `install-rocky-linux.sh` - Script automático de instalação
- `CORRECOES_INSPECTION_CONTROLLER.md` - Correções aplicadas no código

## ❓ Precisa de Ajuda?

1. Verifique os logs: `storage/logs/laravel.log`
2. Leia `SOLUCAO_BROKEN_PIPE.md` para detalhes
3. Use o script otimizado: `./start-dev.sh`
4. Considere usar Laravel Valet para desenvolvimento

---

**Desenvolvido com ❤️ para facilitar seu trabalho**
