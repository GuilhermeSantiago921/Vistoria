<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CheckPaymentMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (Auth::check() && Auth::user()->inspection_credits > 0) {
            return $next($request);
        }

        return redirect()->route('payment.form')->with('error', 'Por favor, realize o pagamento para enviar uma nova vistoria.');
    }
}