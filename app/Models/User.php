<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use App\Models\Vehicle; // <-- NOVO: Importa o modelo Vehicle
use App\Models\Inspection; // <-- NOVO: Importa o modelo Inspection

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role', // Correção anterior mantida
        'inspection_credits',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Define o relacionamento: um usuário (cliente/analista) tem muitos veículos.
     * Isso permite que o AdminController carregue o histórico do usuário.
     */
    public function vehicles()
    {
        // Assume que a chave estrangeira na tabela 'vehicles' é 'user_id'
        return $this->hasMany(Vehicle::class, 'user_id');
    }

    /**
     * Define o relacionamento: um analista tem muitas vistorias.
     * Relacionamento com a tabela inspections via analyst_id.
     */
    public function inspections()
    {
        return $this->hasMany(Inspection::class, 'analyst_id');
    }

    /**
     * Verifica se o usuário tem créditos suficientes para uma nova vistoria.
     */
    public function hasCredits(): bool
    {
        return $this->inspection_credits > 0;
    }

    /**
     * PATCH 4: Consome um crédito de vistoria com lock pessimista (evita race condition)
     * 
     * Usa lockForUpdate() para garantir que apenas uma transação por vez
     * possa modificar os créditos deste usuário
     */
    public function consumeCredit(): bool
    {
        return \DB::transaction(function () {
            // Lock pessimista: bloqueia o registro até o fim da transação
            $user = User::where('id', $this->id)->lockForUpdate()->first();
            
            if ($user->inspection_credits > 0) {
                $user->decrement('inspection_credits');
                return true;
            }
            
            return false;
        });
    }

    /**
     * Adiciona créditos de vistoria.
     */
    public function addCredits(int $amount): void
    {
        $this->increment('inspection_credits', $amount);
    }

    /**
     * Define o total de créditos de vistoria.
     */
    public function setCredits(int $amount): void
    {
        $this->update(['inspection_credits' => $amount]);
    }

    /**
     * Retorna o valor total em reais dos créditos do usuário.
     */
    public function getCreditsValue(): float
    {
        return $this->inspection_credits * config('inspection.credit_price');
    }

    /**
     * Retorna o valor formatado em reais dos créditos do usuário.
     */
    public function getFormattedCreditsValue(): string
    {
        return 'R$ ' . number_format($this->getCreditsValue(), 2, ',', '.');
    }

    /**
     * Calcula o valor de uma quantidade específica de créditos.
     */
    public static function calculateCreditsValue(int $credits): float
    {
        return $credits * config('inspection.credit_price');
    }

    /**
     * Formata um valor monetário para o padrão brasileiro.
     */
    public static function formatMoney(float $value): string
    {
        return 'R$ ' . number_format($value, 2, ',', '.');
    }
}