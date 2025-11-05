<?php

namespace App\Providers;

use App\Http\Middleware\AnalystMiddleware;
use App\Http\Middleware\CheckPaymentMiddleware;
use App\Http\Middleware\AdminMiddleware; // <-- AdminMiddleware deve estar aqui!
use Illuminate\Support\ServiceProvider;
use Illuminate\Routing\Router;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\View;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(Router::class, function ($app) {
            $router = new Router($app['events']);
            
            // Adicione seus middlewares aqui
            $router->aliasMiddleware('analyst', AnalystMiddleware::class);
            $router->aliasMiddleware('check.payment', CheckPaymentMiddleware::class);
            $router->aliasMiddleware('admin', AdminMiddleware::class); // <-- E aqui
            
            return $router;
        });
    }

    public function boot(): void
{
    // NOVO: View Composer para aplicar a classe 'dark'
    View::composer('layouts.app', function ($view) {
        // Assume modo claro se não estiver logado ou se for false
        $darkMode = Auth::check() && Auth::user()->dark_mode;
        $view->with('darkMode', $darkMode);
    });
    // ... restante do seu código
}
}