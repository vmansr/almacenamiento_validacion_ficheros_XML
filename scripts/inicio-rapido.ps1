param(
  [switch]$GenerarReporte
)

$ErrorActionPreference = "Stop"

$null = Get-Command docker -ErrorAction SilentlyContinue
if (-not $?) {
  throw "Docker no esta instalado o no esta en PATH."
}

docker info *> $null
if ($LASTEXITCODE -ne 0) {
  throw "Docker Desktop no esta iniciado. Abre Docker Desktop y vuelve a ejecutar este script."
}

Write-Output "[1/4] Levantando contenedor eXist-db..."
docker compose up -d
if ($LASTEXITCODE -ne 0) {
  throw "No se pudo levantar docker compose."
}

Write-Output "Esperando que eXist-db este listo..."
$maxWait = 60
$waited = 0
$ready = $false
while ($waited -lt $maxWait) {
  $code = & curl.exe -s -o NUL -w "%{http_code}" "http://localhost:8081/exist/rest/db" 2>$null
  if ($code -eq "200" -or $code -eq "401") {
    $ready = $true
    break
  }
  Start-Sleep -Seconds 2
  $waited += 2
  Write-Output "  ... $waited s (estado: $code)"
}

if (-not $ready) {
  throw "eXist-db no respondio en $maxWait segundos. Verifica el contenedor con: docker logs existdb-xml-hr"
}
Write-Output "eXist-db listo."

Write-Output "[2/4] Ejecutando despliegue del proyecto..."
powershell -ExecutionPolicy Bypass -File .\scripts\deploy-exist.ps1
if ($LASTEXITCODE -ne 0) {
  throw "Fallo el script deploy-exist.ps1"
}

if ($GenerarReporte) {
  Write-Output "[3/4] Generando reporte de pruebas..."
  powershell -ExecutionPolicy Bypass -File .\scripts\generar-reporte-pruebas.ps1
  if ($LASTEXITCODE -ne 0) {
    throw "Fallo el script generar-reporte-pruebas.ps1"
  }
}
else {
  Write-Output "[3/4] Reporte omitido (use -GenerarReporte para incluirlo)."
}

$frontendUrl = "http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260519c"
Write-Output "[4/4] Abriendo frontend: $frontendUrl"
Start-Process $frontendUrl

Write-Output ""
Write-Output "Inicio rapido completado."
Write-Output "Si necesitas apagar al terminar: docker compose stop"
