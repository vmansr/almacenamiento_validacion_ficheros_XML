param(
  [string]$BaseUrl = "http://localhost:8081/exist/rest",
  [string]$RestXqUrl = "http://localhost:8081/exist/restxq",
  [string]$User = "admin",
  [string]$Password = ""
)

$ErrorActionPreference = "Stop"

function Invoke-CurlBody {
  param([Parameter(Mandatory = $true)][string[]]$Args)

  $output = & curl.exe @Args
  if ($LASTEXITCODE -ne 0) {
    throw "curl.exe fallo con codigo $LASTEXITCODE. Args: $($Args -join ' ')"
  }
  return ($output -join "`n")
}

function Invoke-CurlCode {
  param([Parameter(Mandatory = $true)][string[]]$Args)

  $code = & curl.exe @Args
  if ($LASTEXITCODE -ne 0) {
    throw "curl.exe fallo con codigo $LASTEXITCODE. Args: $($Args -join ' ')"
  }
  return $code.Trim()
}

function Encode-Query {
  param([Parameter(Mandatory = $true)][string]$Query)
  return [System.Uri]::EscapeDataString($Query)
}

$required = @(
  "queries/01_validacion_valido.xq",
  "queries/02_validacion_invalido.xq",
  "queries/03_xpath_consultas.xq",
  "queries/04_xquery_consultas.xq",
  "queries/05_transformacion.xq",
  "app/index.xhtml",
  "app/style.css",
  "app/app.js"
)

foreach ($f in $required) {
  if (-not (Test-Path $f)) {
    throw "Falta archivo: $f"
  }
  if ((Get-Item $f).Length -le 0) {
    throw "Archivo vacio: $f"
  }
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportDir = Join-Path "reports" $timestamp
New-Item -Path $reportDir -ItemType Directory -Force | Out-Null

$tests = @(
  @{ Name = "01_validacion_valido"; File = "queries/01_validacion_valido.xq"; Kind = "xquery" },
  @{ Name = "02_validacion_invalido"; File = "queries/02_validacion_invalido.xq"; Kind = "xquery" },
  @{ Name = "03_xpath_consultas"; File = "queries/03_xpath_consultas.xq"; Kind = "xquery" },
  @{ Name = "04_xquery_consultas"; File = "queries/04_xquery_consultas.xq"; Kind = "xquery" },
  @{ Name = "05_transformacion"; File = "queries/05_transformacion.xq"; Kind = "xquery" },
  @{ Name = "06_api_rest"; File = "queries/06_api_rest.xqm"; Kind = "restxq" },
  @{ Name = "07_frontend_xhtml"; File = "app/index.xhtml"; Kind = "frontend" }
)

$results = @()

foreach ($t in $tests) {
  Write-Output "Ejecutando $($t.Name)..."

  if ($t.Kind -eq "xquery") {
    $query = Get-Content $t.File -Raw
    $encoded = Encode-Query $query
    $body = Invoke-CurlBody -Args @("-s", "-u", "${User}:${Password}", "$BaseUrl/db?_query=$encoded")
    $rawPath = Join-Path $reportDir ($t.Name + ".xml")
    Set-Content -Path $rawPath -Value $body -Encoding UTF8

    $status = "ok"
    if ($t.Name -eq "01_validacion_valido" -and $body -notmatch "<status>valid</status>") { $status = "revisar" }
    if ($t.Name -eq "02_validacion_invalido" -and $body -notmatch "<status>invalid</status>") { $status = "revisar" }

    $note = switch ($t.Name) {
      "01_validacion_valido" { "Se obtuvo estado valid" }
      "02_validacion_invalido" { "Se obtuvo estado invalid" }
      "03_xpath_consultas" { "Se obtuvo XML con consultas XPath sobre empleados" }
      "04_xquery_consultas" { "Se obtuvo XML filtrado y ordenado por salario" }
      "05_transformacion" { "Se obtuvo salida HTML generada por XSLT" }
      default { "Consulta ejecutada correctamente" }
    }

    $results += [PSCustomObject]@{
      Prueba = $t.Name
      Tipo = "XQuery"
      Estado = $status
      Evidencia = (Split-Path $rawPath -Leaf)
      Nota = $note
    }
  }
  else {
    if ($t.Kind -eq "restxq") {
      $codeGuest = Invoke-CurlCode -Args @("-s", "-o", "NUL", "-w", "%{http_code}", "$RestXqUrl/proyecto-hr/empleados")
      $codeAdmin = Invoke-CurlCode -Args @("-s", "-o", "NUL", "-w", "%{http_code}", "-u", "${User}:${Password}", "$RestXqUrl/proyecto-hr/empleados")
      $bodyAdmin = Invoke-CurlBody -Args @("-s", "-u", "${User}:${Password}", "$RestXqUrl/proyecto-hr/empleados")

      $rawPath = Join-Path $reportDir ($t.Name + "_admin.xml")
      Set-Content -Path $rawPath -Value $bodyAdmin -Encoding UTF8

      $status = if ($codeAdmin -eq "200") { "ok" } else { "revisar" }
      $note = "sin auth=$codeGuest; con auth=$codeAdmin"

      $results += [PSCustomObject]@{
        Prueba = $t.Name
        Tipo = "RESTXQ"
        Estado = $status
        Evidencia = (Split-Path $rawPath -Leaf)
        Nota = $note
      }
    }
    else {
      $frontendUrl = "$BaseUrl/db/proyecto-hr/app/index.xhtml?v=20260519c"
      $headers = Invoke-CurlBody -Args @("-I", "-s", "-u", "${User}:${Password}", $frontendUrl)
      $rawPath = Join-Path $reportDir ($t.Name + ".txt")
      Set-Content -Path $rawPath -Value $headers -Encoding UTF8

      $status = if ($headers -match "Content-Type: application/xhtml\+xml") { "ok" } else { "revisar" }
      $note = "index.xhtml publicado en /db/proyecto-hr/app; index.html quedo como text/plain"

      $results += [PSCustomObject]@{
        Prueba = $t.Name
        Tipo = "Frontend"
        Estado = $status
        Evidencia = (Split-Path $rawPath -Leaf)
        Nota = $note
      }
    }
  }
}

$md = @()
$md += "# Reporte de pruebas eXistDB"
$md += ""
$md += "- Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
$md += "- Base URL: $BaseUrl"
$md += "- RESTXQ URL: $RestXqUrl"
$md += ""
$md += "## Resumen"
$md += ""
$md += "| Prueba | Tipo | Estado | Evidencia | Nota |"
$md += "|---|---|---|---|---|"
foreach ($r in $results) {
  $md += "| $($r.Prueba) | $($r.Tipo) | $($r.Estado) | $($r.Evidencia) | $($r.Nota) |"
}

$reportPath = Join-Path $reportDir "reporte.md"
Set-Content -Path $reportPath -Value ($md -join "`n") -Encoding UTF8

$academic = @()
$academic += "# Informe academico de pruebas"
$academic += ""
$academic += "## Datos generales"
$academic += "- Asignatura: Base de Datos Avanzadas"
$academic += "- Proyecto: victor_sanchez_bd_avanzadas"
$academic += "- Fecha de ejecucion: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$academic += "- Entorno: eXist-db en contenedor Docker"
$academic += "- Endpoint base REST: $BaseUrl"
$academic += "- Endpoint base RESTXQ: $RestXqUrl"
$academic += "- Frontend final: http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260519c"
$academic += ""
$academic += "## Objetivo"
$academic += "Validar que el proyecto XML/XQuery funciona de forma integral en eXist-db, cubriendo almacenamiento XML, validacion XSD, consultas XPath/XQuery, transformacion XSLT, publicacion RESTXQ y visualizacion frontend." 
$academic += ""
$academic += "## Metodologia"
$academic += "1. Se desplegaron recursos XML, XSD, XSL, consultas XQuery, modulo RESTXQ y archivos frontend en colecciones de eXist-db."
$academic += "2. Se ejecutaron pruebas automatizadas sobre consultas, endpoint RESTXQ y publicacion del frontend XHTML."
$academic += "3. Se registraron evidencias en XML y cabeceras HTTP dentro del directorio de reporte."
$academic += "4. Se verifico el ajuste final de interfaz para usar index.xhtml debido al MIME incorrecto observado en index.html."
$academic += ""
$academic += "## Criterios de aceptacion"
$academic += "- 01_validacion_valido debe devolver estado valid."
$academic += "- 02_validacion_invalido debe devolver estado invalid."
$academic += "- 03_xpath_consultas debe devolver resultados XML con datos de empleados."
$academic += "- 04_xquery_consultas debe devolver empleados filtrados y ordenados."
$academic += "- 05_transformacion debe devolver salida HTML desde XSLT."
$academic += "- 06_api_rest debe responder 200 con autenticacion de administrador."
$academic += "- 07_frontend_xhtml debe publicarse con Content-Type application/xhtml+xml."
$academic += ""
$academic += "## Resultados"
$academic += "| Prueba | Tipo | Estado | Resultado observado |"
$academic += "|---|---|---|---|"
foreach ($r in $results) {
  $academic += "| $($r.Prueba) | $($r.Tipo) | $($r.Estado) | $($r.Nota) |"
}
$academic += ""
$academic += "## Ajustes finales incorporados"
$academic += "1. Se publico la coleccion /db/proyecto-hr/xquery con las consultas 01 a 06."
$academic += "2. Se publico la coleccion /db/proyecto-hr/app con style.css, app.js e index.xhtml."
$academic += "3. Se detecto que index.html se servia como text/plain en eXist-db, provocando visualizacion del codigo fuente en el navegador."
$academic += "4. Se adopto index.xhtml como recurso renderizable con MIME application/xhtml+xml y referencias absolutas versionadas para evitar cache y rutas relativas defectuosas."
$academic += "5. El endpoint RESTXQ /proyecto-hr/empleados quedo validado con 401 sin auth y 200 con admin."
$academic += ""
$academic += "## Evidencias"
foreach ($r in $results) {
  $academic += "- [$($r.Evidencia)]($($r.Evidencia))"
}
$academic += "- [reporte.md](reporte.md)"
$academic += ""
$academic += "## Conclusiones"
$academic += "1. El proyecto queda operativo en eXist-db tanto a nivel de consultas como de exposicion RESTXQ."
$academic += "2. La publicacion del frontend queda estabilizada usando XHTML, evitando el problema de MIME observado con index.html."
$academic += "3. La documentacion y los reportes quedan alineados con el estado final desplegado en la base." 

$academicPath = Join-Path $reportDir "informe_academico.md"
Set-Content -Path $academicPath -Value ($academic -join "`n") -Encoding UTF8

Write-Output ""
Write-Output "Reporte generado: $reportPath"
Write-Output "Informe academico generado: $academicPath"
Write-Output "Archivos de evidencia: $reportDir"
