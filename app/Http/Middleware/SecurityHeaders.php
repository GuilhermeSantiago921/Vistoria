<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SecurityHeaders
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Previne clickjacking
        $response->headers->set('X-Frame-Options', 'SAMEORIGIN');
        
        // Previne MIME type sniffing
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        
        // XSS Protection (legacy, mas ainda útil)
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        
        // Política de Referrer
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        
        // Content Security Policy - Ajustado para páginas públicas e autenticadas
        $isPublicPage = in_array($request->path(), ['', '/', 'login', 'register']);
        
        if ($isPublicPage) {
            // CSP mais permissivo para páginas públicas (Welcome, Login, Register)
            $response->headers->set('Content-Security-Policy', 
                "default-src 'self'; " .
                "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.tailwindcss.com https://cdn.jsdelivr.net; " .
                "script-src-attr 'unsafe-inline'; " .
                "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://fonts.bunny.net https://cdn.tailwindcss.com; " .
                "img-src 'self' data: https: blob:; " .
                "font-src 'self' https://fonts.gstatic.com https://fonts.bunny.net data:; " .
                "connect-src 'self'; " .
                "frame-ancestors 'self';"
            );
        } else {
            // CSP para área autenticada (permite Alpine.js)
            $response->headers->set('Content-Security-Policy', 
                "default-src 'self'; " .
                "script-src 'self' 'unsafe-eval' https://cdn.jsdelivr.net; " .
                "script-src-attr 'unsafe-inline'; " .
                "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://fonts.bunny.net; " .
                "img-src 'self' data: https: blob:; " .
                "font-src 'self' https://fonts.gstatic.com https://fonts.bunny.net data:; " .
                "connect-src 'self'; " .
                "frame-ancestors 'self';"
            );
        }
        
        // Permissions Policy (Feature Policy)
        $response->headers->set('Permissions-Policy', 
            'geolocation=(), microphone=(), camera=()'
        );

        // HSTS (HTTP Strict Transport Security) - apenas se estiver em HTTPS
        if ($request->secure()) {
            $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        }

        return $response;
    }
}
