# 🔧 IMPLEMENTAÇÃO DE CORREÇÕES - SECURITY PATCHES

## Patch 1: Adicionar Rate Limiting no Controller

```php
// Em app/Http/Controllers/InspectionController.php
use Illuminate\Cache\RateLimiter;

class InspectionController extends Controller
{
    public function store(Request $request)
    {
        // Rate Limit: máximo 10 vistorias por hora por usuário
        $rateLimiter = resolve(RateLimiter::class);
        
        if ($rateLimiter->tooManyAttempts('inspection-store:' . Auth::id(), 10)) {
            return redirect()->back()->with('error', 
                'Você excedeu o limite de inspeções por hora. Tente novamente mais tarde.'
            );
        }
        
        $rateLimiter->hit('inspection-store:' . Auth::id(), 3600);
        
        // ... resto do código
    }
}
```

## Patch 2: Proteger Acesso a Uploads

```php
// Em app/Http/Controllers/InspectionController.php
use Illuminate\Support\Facades\Storage;

Route::get('/inspection/{inspection}/photo/{filename}', function ($inspection, $filename) {
    $inspection = Inspection::findOrFail($inspection);
    
    // Verificar se usuário é dono, analista ou admin
    if (Auth::id() !== $inspection->user_id && !in_array(Auth::user()->role, ['analyst', 'admin'])) {
        abort(403);
    }
    
    $path = "inspections/{$inspection->id}/{$filename}";
    if (!Storage::disk('public')->exists($path)) {
        abort(404);
    }
    
    return Storage::disk('public')->download($path);
})->name('inspection.photo');
```

## Patch 3: Adicionar Soft Delete em Inspection

```php
// Em app/Models/Inspection.php
use Illuminate\Database\Eloquent\SoftDeletes;

class Inspection extends Model
{
    use SoftDeletes;
    
    protected $dates = ['deleted_at'];
}
```

## Patch 4: Melhorar Tratamento de Exceções com Estrutura

```php
// Em app/Http/Controllers/InspectionController.php
use Illuminate\Validation\ValidationException;
use Illuminate\Database\QueryException;

try {
    DB::transaction(function () use ($request, $dados_agregados) {
        // ... código ...
    });
    
    return redirect()->route('dashboard')
        ->with('success', 'Vistoria enviada com sucesso!');
        
} catch (ValidationException $e) {
    \Log::warning('Validation failed', ['errors' => $e->errors()]);
    return redirect()->back()->withErrors($e->errors())->withInput();
    
} catch (QueryException $e) {
    \Log::error('Database error', ['message' => $e->getMessage()]);
    return redirect()->back()->with('error', 'Erro ao processar vistoria. Contate o administrador.');
    
} catch (\Exception $e) {
    \Log::error('Unexpected error', [
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);
    return redirect()->back()->with('error', 'Erro inesperado ao enviar vistoria.');
}
```

## Patch 5: Adicionar Validação Total de Upload

```php
// Limitar tamanho total de upload para 30MB máximo
$request->validate([
    'front_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'back_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'right_side_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'left_side_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'right_window_engraving_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'left_window_engraving_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'chassis_engraving_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'eta_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'odometer_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
    'engine_photo' => 'required|image|mimes:jpeg,png,jpg|max:3120',
], [
    'max' => 'Tamanho total de upload não pode exceder 30MB.',
]);
```

## Patch 6: Adicionar Cache em Dashboard Admin

```php
// Em app/Http/Controllers/AdminController.php
use Illuminate\Support\Facades\Cache;

public function index(Request $request)
{
    $cacheKey = 'admin_dashboard_' . Auth::id();
    
    $data = Cache::remember($cacheKey, 3600, function () use ($request) {
        $query = Inspection::with(['vehicle.user', 'analyst']);
        
        if ($request->filled('plate')) {
            $plate = $request->input('plate');
            $query->whereHas('vehicle', function ($q) use ($plate) {
                $q->where('license_plate', 'like', '%' . $plate . '%');
            });
        }
        
        if ($request->filled('date')) {
            $date = $request->input('date');
            $query->whereDate('created_at', $date);
        }
        
        return [
            'inspections' => $query->latest()->get(),
            'user_count' => User::count(),
            'analyst_count' => User::where('role', 'analyst')->count(),
        ];
    });
    
    return view('admin.dashboard', $data);
}
```

## Patch 7: Adicionar Audit Trail

```php
// Criar migration
php artisan make:model AuditLog -m

// Em app/Models/AuditLog.php
class AuditLog extends Model
{
    protected $fillable = [
        'user_id',
        'action',
        'model_type',
        'model_id',
        'changes',
        'ip_address',
    ];
}

// Em app/Models/Inspection.php
protected static function booted()
{
    static::updated(function ($model) {
        AuditLog::create([
            'user_id' => Auth::id(),
            'action' => 'updated',
            'model_type' => self::class,
            'model_id' => $model->id,
            'changes' => json_encode($model->getChanges()),
            'ip_address' => request()->ip(),
        ]);
    });
}
```

---

## Verificação de Checklist

- [x] Transação de salvamento implementada
- [ ] Rate limiting não implementado
- [ ] Proteção de upload não implementada
- [ ] Soft delete não implementado
- [ ] Cache de dashboard não implementado
- [ ] Audit trail não implementado
- [x] Validação de créditos implementada
- [x] Notificações implementadas

---

**Prioridade:** Implementar patches 1-3 antes do deploy em produção
