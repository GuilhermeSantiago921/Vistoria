<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AnalystMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (Auth::check() && Auth::user()->role === 'analyst') {
            return $next($request);
        }

        return redirect('/')->with('error', 'Acesso negado. Você não tem permissão para acessar esta página.');
    }
}