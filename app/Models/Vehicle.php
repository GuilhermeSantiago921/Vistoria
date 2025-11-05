<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Vehicle extends Model
{
    use HasFactory;

    /**
     * Os atributos que podem ser atribuídos em massa.
     * ATUALIZADO para corresponder ao InspectionController e ao PDF.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'license_plate',    // <-- Atualizado de 'placa'
        'vin',              // <-- Atualizado de 'chassi'
        'engine_number',    // <-- Atualizado de 'motor'
        'brand',            // <-- Atualizado de 'marca'
        'model',            // <-- Adicionado (o controller já usa)
        'year',             // <-- Atualizado de 'ano_fabricacao' / 'ano_modelo'
        'odometer',         // <-- Atualizado de 'hodometro'
        'color',            // <-- Atualizado de 'cor'
        'fuel_type',        // <-- Atualizado de 'combustivel'
    ];


    /**
     * Define o relacionamento: Um veículo pertence a um usuário.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Define o relacionamento: Um veículo pode ter muitas vistorias.
     */
    public function inspections(): HasMany
    {
        return $this->hasMany(Inspection::class);
    }
}