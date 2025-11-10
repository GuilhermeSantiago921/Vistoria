#!/usr/bin/env php
<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$inspection = App\Models\Inspection::find(2);
if (!$inspection) { echo "inspection not found\n"; exit(1); }

$placa = strtoupper(str_replace('-', '', $inspection->vehicle->license_plate ?? ''));

$query = "
SELECT TOP 1
  A.NR_Chassi, A.NR_Motor, A.NR_AnoFabricacao, A.NR_AnoModelo, C.NM_MarcaModelo,
  I.NM_CorVeiculo, D.NM_Combustivel
FROM VeiculosAgregados.dbo.Agregados2020 A
LEFT JOIN VeiculosAgregados.dbo.TB_ModeloVeiculo C ON CAST(A.CD_MarcaModelo AS FLOAT) = C.CD_MarcaModelo
LEFT JOIN VeiculosAgregados.dbo.TB_Combustivel D ON CAST(A.CD_Combustivel AS FLOAT) = D.CD_Combustivel
LEFT JOIN VeiculosAgregados.dbo.TB_CorVeiculo I ON CAST(A.CD_CorVeiculo AS FLOAT) = I.CD_CorVeiculo
WHERE (NR_PlacaModeloAntigo = ? OR NR_PlacaModeloNovo = ?)
AND A.NR_AnoFabricacao IS NOT NULL
";

$res = DB::connection('sqlsrv_agregados')->select($query, [$placa, $placa]);

if (empty($res)) {
    echo "no data found for plate {$placa}\n";
    exit(0);
}

$dados = (array) $res[0];

$inspection->vehicle->update([
    'vin' => $dados['NR_Chassi'] ?? null,
    'engine_number' => $dados['NR_Motor'] ?? null,
    'brand' => $dados['NM_MarcaModelo'] ?? $inspection->vehicle->brand,
    'model' => $dados['NM_MarcaModelo'] ?? $inspection->vehicle->model,
    'color' => $dados['NM_CorVeiculo'] ?? $inspection->vehicle->color,
    'fuel_type' => $dados['NM_Combustivel'] ?? $inspection->vehicle->fuel_type,
    'year' => isset($dados['NR_AnoFabricacao']) ? (int)$dados['NR_AnoFabricacao'] : $inspection->vehicle->year,
]);

echo "vehicle updated\n";
print_r($inspection->vehicle->fresh()->toArray());
