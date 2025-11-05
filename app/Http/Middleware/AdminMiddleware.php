<?php

namespace App\Http\Middleware; // <-- O namespace precisa ser EXATAMENTE este

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (Auth::check() && Auth::user()->role === 'admin') {
            return $next($request);
        }

        // Se não for admin, redireciona para a home
        return redirect('/')->with('error', 'Acesso negado. Você precisa ser um administrador.');
    }
}