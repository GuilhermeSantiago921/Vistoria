<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Sistema de Vistoria - Configurações
    |--------------------------------------------------------------------------
    */

    /*
    |--------------------------------------------------------------------------
    | Preço por Crédito de Vistoria
    |--------------------------------------------------------------------------
    |
    | Valor em reais (R$) de cada crédito de vistoria.
    | Este valor é usado para calcular o custo total quando créditos são
    | adicionados ou consumidos no sistema.
    |
    */

    'credit_price' => env('INSPECTION_CREDIT_PRICE', 25.00),

    /*
    |--------------------------------------------------------------------------
    | Configurações de Pagamento
    |--------------------------------------------------------------------------
    */

    'payment' => [
        'currency' => 'BRL',
        'currency_symbol' => 'R$',
        'min_credits_purchase' => 1,
        'max_credits_purchase' => 100,
    ],

    /*
    |--------------------------------------------------------------------------
    | Configurações de Negócio
    |--------------------------------------------------------------------------
    */

    'business' => [
        'company_name' => env('COMPANY_NAME', 'VistoriaCar'),
        'contact_email' => env('CONTACT_EMAIL', 'contato@vistoriacar.com.br'),
        'support_phone' => env('SUPPORT_PHONE', '(11) 9999-9999'),
    ],

];
