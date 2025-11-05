#!/bin/bash

# 1. Otimiza a configuração (Obrigatório em produção)
#    Vamos executar isto primeiro para garantir que tudo está pronto
php artisan config:cache
php artisan route:cache

# 2. Cria o link de armazenamento
#    (Remove o antigo se existir, para evitar erros no deploy)
rm -f public/storage
php artisan storage:link

# 3. Executa as migrações da base de dados
php artisan migrate --force

# 4. Inicia o servidor PHP-FPM
#    Este é o comando que mantém o seu site online
php-fpm