<?php

namespace App\Http\Middleware;

use Illuminate\Http\Middleware\TrustProxies as Middleware;
use Illuminate\Http\Request;

class TrustProxies extends Middleware
{
    /**
     * The trusted proxies for this application.
     * 
     * CLOUDFLARE: Usando '*' para confiar em todos os proxies
     * Isso é necessário porque o Cloudflare atua como proxy reverso
     * e envia headers X-Forwarded-* que o Laravel precisa confiar.
     *
     * @var array<int, string>|string|null
     */
    protected $proxies = '*';

    /**
     * The headers that should be used to detect proxies.
     * 
     * Cloudflare envia estes headers:
     * - CF-Connecting-IP: IP real do visitante
     * - X-Forwarded-For: Lista de IPs
     * - X-Forwarded-Proto: http ou https
     *
     * @var int
     */
    protected $headers =
        Request::HEADER_X_FORWARDED_FOR |
        Request::HEADER_X_FORWARDED_HOST |
        Request::HEADER_X_FORWARDED_PORT |
        Request::HEADER_X_FORWARDED_PROTO |
        Request::HEADER_X_FORWARDED_AWS_ELB;
}
