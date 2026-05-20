param(
  [string]$BaseUrl = "http://localhost:8081/exist/rest",
  [string]$RestXqUrl = "http://localhost:8081/exist/restxq",
  [string]$User = "admin",
  [string]$Password = ""
)

$ErrorActionPreference = "Stop"

function Invoke-Curl {
  param(
    [Parameter(Mandatory = $true)][string[]]$Args,
    [switch]$ReturnBody
  )

  $output = & curl.exe @Args
  if ($LASTEXITCODE -ne 0) {
    throw "curl.exe fallo con codigo $LASTEXITCODE. Args: $($Args -join ' ')"
  }

  if ($ReturnBody) {
    return ($output -join "`n")
  }
}

function MkCol {
  param([Parameter(Mandatory = $true)][string]$Url)

  $headCode = & curl.exe -s -o NUL -w "%{http_code}" -u "${User}:${Password}" $Url
  $headCode = $headCode.Trim()
  if ($headCode -eq "200") {
    return
  }

  $collectionPath = $Url.Replace($BaseUrl, "")
  $lastSlash = $collectionPath.LastIndexOf("/")
  if ($lastSlash -lt 0) {
    throw "Ruta de coleccion invalida: $Url"
  }

  $parentPath = $collectionPath.Substring(0, $lastSlash)
  $collectionName = $collectionPath.Substring($lastSlash + 1)

  $query = @"
xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
let $result := xmldb:create-collection(xs:anyURI("$parentPath"), "$collectionName")
return <result>{$result}</result>
"@

  $body = Invoke-Curl -Args @("-s", "-u", "${User}:${Password}", "$BaseUrl/db?_query=$(Encode-Query $query)") -ReturnBody
  if ($body -notmatch "<result>") {
    throw "No se pudo crear la coleccion $collectionPath. Respuesta: $body"
  }
}

function PutFile {
  param(
    [Parameter(Mandatory = $true)][string]$LocalPath,
    [Parameter(Mandatory = $true)][string]$RemoteUrl,
    [string]$ContentType = "application/xml"
  )

  if (-not (Test-Path $LocalPath)) {
    throw "No existe archivo local: $LocalPath"
  }

  $code = & curl.exe -s -o NUL -w "%{http_code}" -u "${User}:${Password}" -X PUT -H "Content-Type: $ContentType" --data-binary "@$LocalPath" $RemoteUrl
  $code = $code.Trim()
  if ($code -ne "201") {
    throw "Error subiendo $LocalPath a $RemoteUrl. HTTP $code"
  }
}

function Encode-Query {
  param([Parameter(Mandatory = $true)][string]$Query)
  return [System.Uri]::EscapeDataString($Query)
}

Write-Output "[1/7] Verificando archivos locales..."
$required = @(
  "data/departamentos.xml",
  "data/departamentos_invalido.xml",
  "data/departamentos.xsd",
  "data/departamentos.xsl",
  "queries/01_validacion_valido.xq",
  "queries/02_validacion_invalido.xq",
  "queries/03_xpath_consultas.xq",
  "queries/04_xquery_consultas.xq",
  "queries/05_transformacion.xq",
  "queries/06_api_rest.xqm",
  "queries/07_esquema_hr_completo.xq",
  "config/collection.xconf",
  "app/index.xhtml",
  "app/style.css",
  "app/app.js"
)

foreach ($f in $required) {
  if (-not (Test-Path $f)) {
    throw "Falta archivo requerido: $f"
  }
  $len = (Get-Item $f).Length
  if ($len -le 0) {
    throw "Archivo vacio detectado: $f"
  }
}

Write-Output "[2/7] Creando colecciones de datos..."
MkCol "$BaseUrl/db/proyecto-hr"
MkCol "$BaseUrl/db/proyecto-hr/xml"
MkCol "$BaseUrl/db/proyecto-hr/schema"
MkCol "$BaseUrl/db/proyecto-hr/xslt"
MkCol "$BaseUrl/db/proyecto-hr/xquery"
MkCol "$BaseUrl/db/proyecto-hr/app"

Write-Output "[3/7] Subiendo XML/XSD/XSL..."
PutFile "data/departamentos.xml" "$BaseUrl/db/proyecto-hr/xml/departamentos.xml"
PutFile "data/departamentos_invalido.xml" "$BaseUrl/db/proyecto-hr/xml/departamentos_invalido.xml"
PutFile "data/departamentos.xsd" "$BaseUrl/db/proyecto-hr/schema/departamentos.xsd"
PutFile "data/departamentos.xsl" "$BaseUrl/db/proyecto-hr/xslt/departamentos.xsl"
PutFile "queries/01_validacion_valido.xq" "$BaseUrl/db/proyecto-hr/xquery/01_validacion_valido.xq" "application/xquery"
PutFile "queries/02_validacion_invalido.xq" "$BaseUrl/db/proyecto-hr/xquery/02_validacion_invalido.xq" "application/xquery"
PutFile "queries/03_xpath_consultas.xq" "$BaseUrl/db/proyecto-hr/xquery/03_xpath_consultas.xq" "application/xquery"
PutFile "queries/04_xquery_consultas.xq" "$BaseUrl/db/proyecto-hr/xquery/04_xquery_consultas.xq" "application/xquery"
PutFile "queries/05_transformacion.xq" "$BaseUrl/db/proyecto-hr/xquery/05_transformacion.xq" "application/xquery"
PutFile "queries/07_esquema_hr_completo.xq" "$BaseUrl/db/proyecto-hr/xquery/07_esquema_hr_completo.xq" "application/xquery"
PutFile "app/index.xhtml" "$BaseUrl/db/proyecto-hr/app/index.xhtml" "application/xhtml+xml"
PutFile "app/style.css" "$BaseUrl/db/proyecto-hr/app/style.css" "text/css"
PutFile "app/app.js" "$BaseUrl/db/proyecto-hr/app/app.js" "application/javascript"

Write-Output "[4/7] Aplicando configuracion de trigger RESTXQ..."
MkCol "$BaseUrl/db/system"
MkCol "$BaseUrl/db/system/config"
MkCol "$BaseUrl/db/system/config/db"
MkCol "$BaseUrl/db/system/config/db/apps"
MkCol "$BaseUrl/db/system/config/db/apps/proyecto-hr"
MkCol "$BaseUrl/db/system/config/db/apps/proyecto-hr/modules"
PutFile "config/collection.xconf" "$BaseUrl/db/system/config/db/apps/proyecto-hr/modules/collection.xconf"

Write-Output "[5/7] Desplegando modulo RESTXQ..."
MkCol "$BaseUrl/db/apps"
MkCol "$BaseUrl/db/apps/proyecto-hr"
MkCol "$BaseUrl/db/apps/proyecto-hr/modules"
PutFile "queries/06_api_rest.xqm" "$BaseUrl/db/apps/proyecto-hr/modules/06_api_rest.xqm" "application/xquery"

Write-Output "[6/7] Limpiando artefactos temporales..."
& curl.exe -s -o NUL -w "%{http_code}" -u "${User}:${Password}" -X DELETE "$BaseUrl/db/proyecto-hr/schema/_tmp.xml" | Out-Null

Write-Output "[7/7] Ejecutando pruebas rapidas..."

$qValid = @'
xquery version "3.1";
import module namespace validation="http://exist-db.org/xquery/validation";
let $xml := doc("/db/proyecto-hr/xml/departamentos.xml")
let $xsd := doc("/db/proyecto-hr/schema/departamentos.xsd")
return validation:jaxv-report($xml, $xsd, xs:anyURI("http://www.w3.org/2001/XMLSchema"))
'@

$qInvalid = @'
xquery version "3.1";
import module namespace validation="http://exist-db.org/xquery/validation";
let $xml := doc("/db/proyecto-hr/xml/departamentos_invalido.xml")
let $xsd := doc("/db/proyecto-hr/schema/departamentos.xsd")
return validation:jaxv-report($xml, $xsd, xs:anyURI("http://www.w3.org/2001/XMLSchema"))
'@

$qTransform = @'
xquery version "3.1";
import module namespace transform="http://exist-db.org/xquery/transform";
let $xml := doc("/db/proyecto-hr/xml/departamentos.xml")
let $xsl := doc("/db/proyecto-hr/xslt/departamentos.xsl")
return transform:transform($xml, $xsl, ())
'@

$validBody = Invoke-Curl -Args @("-s", "-u", "${User}:${Password}", "$BaseUrl/db?_query=$(Encode-Query $qValid)") -ReturnBody
$invalidBody = Invoke-Curl -Args @("-s", "-u", "${User}:${Password}", "$BaseUrl/db?_query=$(Encode-Query $qInvalid)") -ReturnBody
$transformBody = Invoke-Curl -Args @("-s", "-u", "${User}:${Password}", "$BaseUrl/db?_query=$(Encode-Query $qTransform)") -ReturnBody

$restCodeGuest = & curl.exe -s -o NUL -w "%{http_code}" "$RestXqUrl/proyecto-hr/empleados"
$restCodeGuest = $restCodeGuest.Trim()
$restCodeAdmin = & curl.exe -s -o NUL -w "%{http_code}" -u "${User}:${Password}" "$RestXqUrl/proyecto-hr/empleados"
$restCodeAdmin = $restCodeAdmin.Trim()

Write-Output ""
Write-Output "=== RESULTADOS ==="
Write-Output "Validacion XML valido: "
if ($validBody -match "<status>valid</status>") { Write-Output "OK (valid)" } else { Write-Output "Revisar salida:"; Write-Output $validBody }

Write-Output "Validacion XML invalido: "
if ($invalidBody -match "<status>invalid</status>") { Write-Output "OK (invalid)" } else { Write-Output "Revisar salida:"; Write-Output $invalidBody }

Write-Output "Transformacion XSLT: "
if ($transformBody -match "<html" -or $transformBody -match "<table") { Write-Output "OK" } else { Write-Output "Revisar salida:"; Write-Output $transformBody }

Write-Output "RESTXQ /proyecto-hr/empleados sin auth: HTTP $restCodeGuest"
Write-Output "RESTXQ /proyecto-hr/empleados con auth admin: HTTP $restCodeAdmin"
if ($restCodeAdmin -ne "200") {
  Write-Output "Aviso: RESTXQ aun no responde 200 con admin."
}

$frontendHeaders = Invoke-Curl -Args @("-I", "-s", "-u", "${User}:${Password}", "$BaseUrl/db/proyecto-hr/app/index.xhtml") -ReturnBody
Write-Output "Frontend /db/proyecto-hr/app/index.xhtml: "
if ($frontendHeaders -match "Content-Type: application/xhtml\+xml") { Write-Output "OK (application/xhtml+xml)" } else { Write-Output "Revisar cabeceras:"; Write-Output $frontendHeaders }

Write-Output ""
Write-Output "Despliegue finalizado."
