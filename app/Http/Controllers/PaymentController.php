<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PaymentController extends Controller
{
    /**
     * Exibe o formulário de pagamento.
     *
     * @return \Illuminate\View\View
     */
    public function showPaymentForm()
    {
        return view('payment.form');
    }

    /**
     * Simula o processamento do pagamento e concede um crédito de vistoria ao usuário.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function processPayment(Request $request)
    {
        $user = Auth::user();
        $user->inspection_credits = 1;
        $user->save();

        return redirect()->route('inspections.create')->with('success', 'Pagamento confirmado! Você já pode enviar sua vistoria.');
    }
}