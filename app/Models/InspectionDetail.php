<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InspectionDetail extends Model
{
    use HasFactory;

    /**
     * Define o nome da tabela, caso seja diferente do padrão (opcional mas boa prática).
     */
    protected $table = 'inspection_details';

    /**
     * Os atributos que podem ser atribuídos em massa.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'inspection_id',
        'item_name',
        'status',
        'observation', // <-- O campo de observação por item 
    ];

    /**
     * Desativa os timestamps (created_at, updated_at) se você não os tiver na migração.
     * Se você tiver, pode remover esta linha.
     */
    public $timestamps = false;

    /**
     * Define o relacionamento: Um detalhe pertence a uma vistoria.
     */
    public function inspection(): BelongsTo
    {
        return $this->belongsTo(Inspection::class);
    }
}