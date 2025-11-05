<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage; // Importado para o Accessor

class InspectionPhoto extends Model
{
    use HasFactory;

    /**
     * Os atributos que podem ser atribuídos em massa.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'inspection_id',
        'path',
        'label', // <-- Adicionado (ex: "Frente Do Veiculo") [cite: 28]
    ];

    /**
     * Define o relacionamento: Uma foto pertence a uma vistoria.
     */
    public function inspection(): BelongsTo
    {
        return $this->belongsTo(Inspection::class);
    }

    /**
     * (BÔNUS) Accessor para obter a URL completa da foto.
     * Isso facilita o uso nas views!
     *
     * No seu HTML/Blade, você pode usar: {{ $photo->url }}
     */
    public function getUrlAttribute(): string
    {
        // Retorna a URL pública completa do arquivo salvo no disco 'public'
        return Storage::disk('public')->url($this->path);
    }
}