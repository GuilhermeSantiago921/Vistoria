<?php

namespace App\Logging;

use Monolog\Processor\ProcessorInterface;

class SanitizeProcessor implements ProcessorInterface
{
    /**
     * Campos sensíveis que devem ser mascarados nos logs
     */
    private array $sensitiveFields = [
        'password',
        'password_confirmation',
        'current_password',
        'new_password',
        'token',
        'secret',
        'api_key',
        'access_token',
        'refresh_token',
        'card_number',
        'cvv',
        'ssn',
    ];

    /**
     * @param array $record
     * @return array
     */
    public function __invoke(array $record): array
    {
        if (isset($record['context'])) {
            $record['context'] = $this->sanitize($record['context']);
        }

        if (isset($record['extra'])) {
            $record['extra'] = $this->sanitize($record['extra']);
        }

        return $record;
    }

    /**
     * Sanitiza dados sensíveis recursivamente
     */
    private function sanitize(array $data): array
    {
        foreach ($data as $key => $value) {
            if (is_array($value)) {
                $data[$key] = $this->sanitize($value);
            } elseif ($this->isSensitiveField($key)) {
                $data[$key] = '***REDACTED***';
            }
        }

        return $data;
    }

    /**
     * Verifica se o campo é sensível
     */
    private function isSensitiveField(string $field): bool
    {
        $field = strtolower($field);
        
        foreach ($this->sensitiveFields as $sensitive) {
            if (str_contains($field, $sensitive)) {
                return true;
            }
        }

        return false;
    }
}
