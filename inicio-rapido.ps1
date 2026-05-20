param(
  [switch]$GenerarReporte
)

$scriptPath = Join-Path $PSScriptRoot "scripts\inicio-rapido.ps1"

if (-not (Test-Path $scriptPath)) {
  throw "No se encontro el script: $scriptPath"
}

if ($GenerarReporte) {
  powershell -ExecutionPolicy Bypass -File $scriptPath -GenerarReporte
}
else {
  powershell -ExecutionPolicy Bypass -File $scriptPath
}
