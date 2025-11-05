<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Settings
    |--------------------------------------------------------------------------
    |
    | ... (código omitido) ...
    |
    */
    'show_warnings' => false,

    'public_path' => null,

    'convert_entities' => true,

    'options' => [
        // ... (código omitido) ...
        'font_dir' => storage_path('fonts'), 
        'font_cache' => storage_path('fonts'),
        'temp_dir' => sys_get_temp_dir(),
        'chroot' => realpath(base_path()),

        // Protocolos permitidos (já está correto)
        'allowed_protocols' => [
            'data://' => ['rules' => []],
            'file://' => ['rules' => []],
            'http://' => ['rules' => []],
            'https://' => ['rules' => []],
        ],

        // ... (código omitido) ...
        'pdf_backend' => 'CPDF',
        'default_media_type' => 'screen',
        'default_paper_size' => 'a4',
        'default_paper_orientation' => 'portrait',
        'default_font' => 'serif',
        'dpi' => 96,
        'enable_php' => false,
        'enable_javascript' => true,

        /**
         * Enable remote file access
         *
         * [Correção: Mudar True para true minúsculo]
         * @var bool
         */
        'enable_remote' => true, // <-- CORREÇÃO AQUI

        'allowed_remote_hosts' => null,
        'font_height_ratio' => 1.1,
        'enable_html5_parser' => true,
    ],

];