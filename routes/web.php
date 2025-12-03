<?php

use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\InspectionController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\AdminController;
use App\Http\Middleware\AnalystMiddleware;
use App\Http\Middleware\CheckPaymentMiddleware;
use App\Http\Middleware\AdminMiddleware;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Rota de Diagnóstico Temporária
|--------------------------------------------------------------------------
| Deletar após a correção do driver SQL Server.
*/
Route::get('/test-db-connection', [InspectionController::class, 'testConnection']);

/*
|--------------------------------------------------------------------------
| Rotas Públicas
|--------------------------------------------------------------------------
*/
Route::get('/', function () {
    return view('welcome');
});

// Inclui as rotas de autenticação (login, registro, etc.)
require __DIR__.'/auth.php';

/*
|--------------------------------------------------------------------------
| Rotas Protegidas (Autenticadas)
|--------------------------------------------------------------------------
*/
Route::middleware(['auth'])->group(function () {
    // Rota do Dashboard inteligente (Redireciona Admin/Analista ou exibe Cliente)
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Rotas de perfil e tema
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
    Route::patch('/user/theme', [ProfileController::class, 'updateTheme'])->name('user.theme.update');
    
    // Rotas de pagamento
    Route::get('/pagamento', [PaymentController::class, 'showPaymentForm'])->name('payment.form');
    Route::post('/pagamento', [PaymentController::class, 'processPayment'])->name('payment.process');

    // Rotas do cliente para Vistoria
    Route::get('/vistoria/nova', [InspectionController::class, 'create'])->middleware(CheckPaymentMiddleware::class)->name('inspections.create');
    Route::post('/vistoria/nova', [InspectionController::class, 'store'])->middleware(CheckPaymentMiddleware::class)->name('inspections.store');
    Route::get('/meus-laudos', [InspectionController::class, 'history'])->name('inspections.history');
    
    // Rota para gerar o PDF (acessível por Analista e Cliente)
    Route::get('/report/inspection/{inspection}/pdf', [ReportController::class, 'generatePdf'])->name('report.inspection.pdf');
});

/*
|--------------------------------------------------------------------------
| Rotas do Analista
|--------------------------------------------------------------------------
*/
Route::middleware(['auth', AnalystMiddleware::class])->prefix('analyst')->group(function () {
    Route::get('/dashboard', [InspectionController::class, 'index'])->name('analyst.dashboard');
    Route::get('/inspections/all', [InspectionController::class, 'all'])->name('analyst.inspections.all');
    Route::get('/inspections/{inspection}', [InspectionController::class, 'show'])->name('analyst.inspections.show');
    Route::post('/inspections/{inspection}/approve', [InspectionController::class, 'approve'])->name('analyst.inspections.approve');
    Route::post('/inspections/{inspection}/disapprove', [InspectionController::class, 'disapprove'])->name('analyst.inspections.disapprove');
    
    // Rota para o analista puxar dados da BIN manualmente
    Route::post('/inspections/{inspection}/pull-data', [InspectionController::class, 'pullAggregates'])->name('analyst.inspections.pull_data');
});

/*
|--------------------------------------------------------------------------
| Rotas do Administrador
|--------------------------------------------------------------------------
*/
Route::middleware(['auth', AdminMiddleware::class])->prefix('admin')->group(function () {
    // Dashboard e Gerência de Vistorias
    Route::get('/dashboard', [AdminController::class, 'index'])->name('admin.dashboard');
    
    // Gerência de Usuários
    Route::get('/users', [AdminController::class, 'listUsers'])->name('admin.users.index');
    Route::get('/users/create', [AdminController::class, 'createUser'])->name('admin.users.create');
    Route::post('/users', [AdminController::class, 'storeUser'])->name('admin.users.store');
    Route::get('/users/{user}', [AdminController::class, 'showUser'])->name('admin.users.show');
    
    // Gerência de Créditos
    Route::get('/credits/manage', [AdminController::class, 'manageCredits'])->name('admin.credits.manage');
    Route::post('/credits/add', [AdminController::class, 'addCredits'])->name('admin.credits.add');
    Route::post('/credits/set', [AdminController::class, 'setCredits'])->name('admin.credits.set');
    Route::get('/credits/history', [AdminController::class, 'creditsHistory'])->name('admin.credits.history');
});