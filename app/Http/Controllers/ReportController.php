<?php

namespace App\Http\Controllers;

use App\Models\Inspection;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    /**
     * Gera o PDF de um laudo de vistoria.
     *
     * @param  \App\Models\Inspection  $inspection
     * @return \Illuminate\Http\Response
     */
    public function generatePdf(Inspection $inspection)
    {
        $pdf = Pdf::loadView('reports.inspection-report', compact('inspection'));
        
        return $pdf->download('laudo_vistoria_' . $inspection->id . '.pdf');
    }
}