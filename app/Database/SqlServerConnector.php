<?php

namespace App\Database;

use Illuminate\Database\Connectors\SqlServerConnector as BaseSqlServerConnector;
use PDO;

/**
 * Connector customizado para SQL Server com suporte a TrustServerCertificate
 * 
 * Necessário porque o ODBC Driver 18 exige SSL por padrão e o servidor
 * usa certificado auto-assinado.
 */
class SqlServerConnector extends BaseSqlServerConnector
{
    /**
     * Create a new PDO connection.
     *
     * @param  string  $dsn
     * @param  array  $config
     * @param  array  $options
     * @return \PDO
     */
    public function createConnection($dsn, array $config, array $options)
    {
        // Adicionar TrustServerCertificate se não estiver no DSN
        if (isset($config['trust_server_certificate']) && $config['trust_server_certificate']) {
            if (strpos($dsn, 'TrustServerCertificate') === false) {
                $dsn .= ';TrustServerCertificate=1';
            }
        }
        
        // Adicionar Encrypt se configurado
        if (isset($config['encrypt'])) {
            if (strpos($dsn, 'Encrypt') === false) {
                $dsn .= ';Encrypt=' . $config['encrypt'];
            }
        }
        
        return parent::createConnection($dsn, $config, $options);
    }
    
    /**
     * Create a DSN string from a configuration.
     *
     * @param  array  $config
     * @return string
     */
    protected function getDsn(array $config)
    {
        $dsn = parent::getDsn($config);
        
        // Adicionar parâmetros de segurança ao DSN
        $params = [];
        
        if (isset($config['trust_server_certificate']) && $config['trust_server_certificate']) {
            $params[] = 'TrustServerCertificate=1';
        }
        
        if (isset($config['encrypt'])) {
            $params[] = 'Encrypt=' . $config['encrypt'];
        }
        
        if (!empty($params)) {
            $dsn .= ';' . implode(';', $params);
        }
        
        return $dsn;
    }
}
