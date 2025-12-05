# 🚀 Scripts de Inicialização - Sistema Vistoria

## Servidor Laravel com Limites de Upload Configurados

### ⚡ Start Rápido
```bash
./start-server.sh
```

### 📋 Configurações Aplicadas
- **upload_max_filesize**: 5MB (tamanho máximo de cada foto)
- **post_max_size**: 35MB (tamanho total do formulário)
- **memory_limit**: 256MB (memória para processar uploads)
- **max_execution_time**: 120s (tempo máximo de execução)

### 🔧 Comando Manual
Se preferir iniciar manualmente:
```bash
php -d upload_max_filesize=5M \
    -d post_max_size=35M \
    -d memory_limit=256M \
    -d max_execution_time=120 \
    artisan serve
```

### 📦 Docker (Produção)
Para ambiente Docker, as configurações estão no `Dockerfile`:
```dockerfile
RUN echo "upload_max_filesize = 5M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 35M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 120" >> /usr/local/etc/php/conf.d/uploads.ini
```

### 🧪 Testar Limites
```bash
# Verificar configurações ativas
php -r "echo 'upload_max_filesize: ' . ini_get('upload_max_filesize') . PHP_EOL;"
php -r "echo 'post_max_size: ' . ini_get('post_max_size') . PHP_EOL;"
php -r "echo 'memory_limit: ' . ini_get('memory_limit') . PHP_EOL;"
```

### ⚠️ IMPORTANTE

**Nosso sistema tem DOIS níveis de validação:**

1. **Nível PHP** (arquivo `.user.ini` ou flags `-d`):
   - `upload_max_filesize = 5M` (cada arquivo)
   - `post_max_size = 35M` (requisição inteira)

2. **Nível Laravel** (`InspectionController.php`):
   - Limite de 30MB para as 10 fotos combinadas
   - Validação de tamanho de arquivo individual

**Por que 35MB no PHP e 30MB no Laravel?**
- Os 35MB do PHP incluem overhead do multipart/form-data (~15-20% extra)
- Os 30MB do Laravel validam apenas o tamanho real das fotos
- Isso garante que uploads legítimos de 30MB sempre passem

### 🔍 Troubleshooting

**Erro `PostTooLargeException`:**
- Servidor não foi iniciado com os parâmetros `-d`
- Use o script `./start-server.sh` ou o comando manual acima

**Erro "O tamanho total das fotos excede o limite de 30MB":**
- Validação do Laravel funcionando corretamente
- Reduza a qualidade/tamanho das imagens antes de enviar

**Upload muito lento:**
- Aumente `max_execution_time` e `max_input_time`
- Considere usar compressão de imagens no frontend

### 📊 Limites Recomendados por Ambiente

| Ambiente | upload_max_filesize | post_max_size | memory_limit |
|----------|-------------------|---------------|--------------|
| Desenvolvimento | 5M | 35M | 256M |
| Staging | 5M | 35M | 512M |
| Produção | 5M | 35M | 512M |

### 🔐 Segurança

✅ **Implementado:**
- Rate limiting (10 vistorias/hora)
- Validação de tamanho total (30MB)
- Validação de tipo MIME
- Verificação de extensão de arquivo

❌ **Não recomendado aumentar além de 5MB por foto:**
- Risco de DoS por uploads massivos
- Impacto no storage
- Tempo de processamento elevado
- Experiência do usuário degradada
