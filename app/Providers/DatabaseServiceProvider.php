<?php

namespace App\Providers;

use App\Database\SqlServerConnector;
use Illuminate\Support\ServiceProvider;
use Illuminate\Database\Connection;
use Illuminate\Database\Connectors\ConnectionFactory;

class DatabaseServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        // Registrar o connector customizado para SQL Server
        $this->app->resolving('db', function ($db) {
            $db->extend('sqlsrv', function ($config, $name) {
                $connector = new SqlServerConnector();
                $connection = $connector->connect($config);
                
                return new \Illuminate\Database\SqlServerConnection(
                    $connection,
                    $config['database'],
                    $config['prefix'],
                    $config
                );
            });
        });
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
