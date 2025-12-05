<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Inspection extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'vehicle_id',
        'user_id', // Adicionado (baseado no seu resumo, o cliente que cria)
        'analyst_id',
        'status',
        'notes', // [cite: 22, 25] (Observações Finais / Parecer Técnico)
    ];

    /**
     * Define o relacionamento: A vistoria pertence a um veículo.
     */
    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(Vehicle::class);
    }

    /**
     * Define o relacionamento: A vistoria pertence a um cliente (solicitante).
     */
    public function client(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id'); // [cite: 15, 19]
    }

    /**
     * Define o relacionamento: A vistoria pertence a um analista.
     */
    public function analyst(): BelongsTo
    {
        return $this->belongsTo(User::class, 'analyst_id'); // [cite: 23]
    }

    /**
     * Define o relacionamento: A vistoria tem muitas fotos.
     */
    public function photos(): HasMany
    {
        return $this->hasMany(InspectionPhoto::class);
    }

    /**
     * NOVO RELACIONAMENTO: A vistoria tem muitos detalhes (itens estruturais).
     */
    public function details(): HasMany
    {
        return $this->hasMany(InspectionDetail::class); // 
    }
}