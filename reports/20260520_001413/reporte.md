# Reporte de pruebas eXistDB

- Fecha: 2026-05-20 00:14:13
- Base URL: http://localhost:8081/exist/rest
- RESTXQ URL: http://localhost:8081/exist/restxq

## Resumen

| Prueba | Tipo | Estado | Evidencia | Nota |
|---|---|---|---|---|
| 01_validacion_valido | XQuery | ok | 01_validacion_valido.xml | Se obtuvo estado valid |
| 02_validacion_invalido | XQuery | ok | 02_validacion_invalido.xml | Se obtuvo estado invalid |
| 03_xpath_consultas | XQuery | ok | 03_xpath_consultas.xml | Se obtuvo XML con consultas XPath sobre empleados |
| 04_xquery_consultas | XQuery | ok | 04_xquery_consultas.xml | Se obtuvo XML filtrado y ordenado por salario |
| 05_transformacion | XQuery | ok | 05_transformacion.xml | Se obtuvo salida HTML generada por XSLT |
| 06_api_rest | RESTXQ | ok | 06_api_rest_admin.xml | sin auth=401; con auth=200 |
| 07_frontend_xhtml | Frontend | ok | 07_frontend_xhtml.txt | index.xhtml publicado en /db/proyecto-hr/app; index.html quedo como text/plain |
