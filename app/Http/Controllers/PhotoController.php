<?php

namespace App\Http\Controllers;

use App\Models\Inspection;
use App\Models\InspectionPhoto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PhotoController extends Controller
{
    /**
     * Download protegido de foto de inspeção
     * 
     * PATCH 3: Proteção de downloads - apenas dono ou analista/admin pode baixar
     */
    public function download(InspectionPhoto $photo): StreamedResponse
    {
        $inspection = $photo->inspection;
        
        // Verificar permissão:
        // 1. Admin pode tudo
        // 2. Analista pode tudo
        // 3. Cliente só pode suas próprias fotos
        if (Auth::user()->role !== 'admin' && 
            Auth::user()->role !== 'analyst' && 
            $inspection->vehicle->user_id !== Auth::id()) {
            abort(403, 'Você não tem permissão para acessar esta foto.');
        }
        
        // Verificar se arquivo existe
        if (!Storage::exists($photo->path)) {
            abort(404, 'Foto não encontrada.');
        }
        
        // Retornar arquivo com nome limpo
        $filename = basename($photo->path);
        
        return Storage::download($photo->path, $filename);
    }
    
    /**
     * Visualizar foto inline (para preview)
     */
    public function show(InspectionPhoto $photo)
    {
        $inspection = $photo->inspection;
        
        // Mesmas permissões do download
        if (Auth::user()->role !== 'admin' && 
            Auth::user()->role !== 'analyst' && 
            $inspection->vehicle->user_id !== Auth::id()) {
            abort(403, 'Você não tem permissão para visualizar esta foto.');
        }
        
        if (!Storage::exists($photo->path)) {
            abort(404, 'Foto não encontrada.');
        }
        
        return response()->file(Storage::path($photo->path));
    }
}
