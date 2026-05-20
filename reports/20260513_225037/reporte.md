# Reporte de pruebas eXistDB

- Fecha: 2026-05-13 22:50:38
- Base URL: http://localhost:8081/exist/rest
- RESTXQ URL: http://localhost:8081/exist/restxq

## Resumen

| Prueba | Tipo | Estado | Evidencia | Nota |
|---|---|---|---|---|
| 01_validacion_valido | XQuery | ok | 01_validacion_valido.xml |  |
| 02_validacion_invalido | XQuery | ok | 02_validacion_invalido.xml |  |
| 03_xpath_consultas | XQuery | ok | 03_xpath_consultas.xml |  |
| 04_xquery_consultas | XQuery | ok | 04_xquery_consultas.xml |  |
| 05_transformacion | XQuery | ok | 05_transformacion.xml |  |
| 06_api_rest | RESTXQ | ok | 06_api_rest_admin.xml | sin auth=401; con auth=200 |

## Cambios efectuados posteriores

- Se creo y verifico la coleccion `/db/proyecto-hr/xquery` en eXist-db.
- Se subieron los recursos:
	- `01_validacion_valido.xq`
	- `02_validacion_invalido.xq`
- Ejecucion directa por URL REST de eXist:
	- `GET /exist/rest/db/proyecto-hr/xquery/01_validacion_valido.xq` -> HTTP 200, `<status>valid</status>`
	- `GET /exist/rest/db/proyecto-hr/xquery/02_validacion_invalido.xq` -> HTTP 200, `<status>invalid</status>`
