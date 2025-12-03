<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class StrongPassword implements ValidationRule
{
    /**
     * Run the validation rule.
     */
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        // Mínimo 8 caracteres
        if (strlen($value) < 8) {
            $fail('A senha deve ter no mínimo 8 caracteres.');
            return;
        }

        // Máximo 64 caracteres (previne ataques DoS)
        if (strlen($value) > 64) {
            $fail('A senha deve ter no máximo 64 caracteres.');
            return;
        }

        // Deve conter pelo menos uma letra maiúscula
        if (!preg_match('/[A-Z]/', $value)) {
            $fail('A senha deve conter pelo menos uma letra maiúscula.');
            return;
        }

        // Deve conter pelo menos uma letra minúscula
        if (!preg_match('/[a-z]/', $value)) {
            $fail('A senha deve conter pelo menos uma letra minúscula.');
            return;
        }

        // Deve conter pelo menos um número
        if (!preg_match('/[0-9]/', $value)) {
            $fail('A senha deve conter pelo menos um número.');
            return;
        }

        // Deve conter pelo menos um caractere especial
        if (!preg_match('/[^A-Za-z0-9]/', $value)) {
            $fail('A senha deve conter pelo menos um caractere especial (@, #, $, etc).');
            return;
        }

        // Previne senhas comuns
        $commonPasswords = [
            'password', '12345678', 'password123', 'admin123', 
            'qwerty123', 'abc12345', 'password1', '123456789'
        ];

        if (in_array(strtolower($value), $commonPasswords)) {
            $fail('Esta senha é muito comum. Escolha uma senha mais segura.');
            return;
        }
    }
}
