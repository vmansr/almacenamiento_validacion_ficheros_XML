# Informe academico de pruebas

## Datos generales
- Asignatura: Base de Datos Avanzadas
- Proyecto: proyecto-eXistdb-xml-hr
- Fecha de ejecucion: 2026-05-20 00:14:13
- Entorno: eXist-db en contenedor Docker
- Endpoint base REST: http://localhost:8081/exist/rest
- Endpoint base RESTXQ: http://localhost:8081/exist/restxq
- Frontend final: http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260514b

## Objetivo
Validar que el proyecto XML/XQuery funciona de forma integral en eXist-db, cubriendo almacenamiento XML, validacion XSD, consultas XPath/XQuery, transformacion XSLT, publicacion RESTXQ y visualizacion frontend.

## Metodologia
1. Se desplegaron recursos XML, XSD, XSL, consultas XQuery, modulo RESTXQ y archivos frontend en colecciones de eXist-db.
2. Se ejecutaron pruebas automatizadas sobre consultas, endpoint RESTXQ y publicacion del frontend XHTML.
3. Se registraron evidencias en XML y cabeceras HTTP dentro del directorio de reporte.
4. Se verifico el ajuste final de interfaz para usar index.xhtml debido al MIME incorrecto observado en index.html.

## Criterios de aceptacion
- 01_validacion_valido debe devolver estado valid.
- 02_validacion_invalido debe devolver estado invalid.
- 03_xpath_consultas debe devolver resultados XML con datos de empleados.
- 04_xquery_consultas debe devolver empleados filtrados y ordenados.
- 05_transformacion debe devolver salida HTML desde XSLT.
- 06_api_rest debe responder 200 con autenticacion de administrador.
- 07_frontend_xhtml debe publicarse con Content-Type application/xhtml+xml.

## Resultados
| Prueba | Tipo | Estado | Resultado observado |
|---|---|---|---|
| 01_validacion_valido | XQuery | ok | Se obtuvo estado valid |
| 02_validacion_invalido | XQuery | ok | Se obtuvo estado invalid |
| 03_xpath_consultas | XQuery | ok | Se obtuvo XML con consultas XPath sobre empleados |
| 04_xquery_consultas | XQuery | ok | Se obtuvo XML filtrado y ordenado por salario |
| 05_transformacion | XQuery | ok | Se obtuvo salida HTML generada por XSLT |
| 06_api_rest | RESTXQ | ok | sin auth=401; con auth=200 |
| 07_frontend_xhtml | Frontend | ok | index.xhtml publicado en /db/proyecto-hr/app; index.html quedo como text/plain |

## Ajustes finales incorporados
1. Se publico la coleccion /db/proyecto-hr/xquery con las consultas 01 a 06.
2. Se publico la coleccion /db/proyecto-hr/app con style.css, app.js e index.xhtml.
3. Se detecto que index.html se servia como text/plain en eXist-db, provocando visualizacion del codigo fuente en el navegador.
4. Se adopto index.xhtml como recurso renderizable con MIME application/xhtml+xml y referencias absolutas versionadas para evitar cache y rutas relativas defectuosas.
5. El endpoint RESTXQ /proyecto-hr/empleados quedo validado con 401 sin auth y 200 con admin.

## Evidencias
- [01_validacion_valido.xml](01_validacion_valido.xml)
- [02_validacion_invalido.xml](02_validacion_invalido.xml)
- [03_xpath_consultas.xml](03_xpath_consultas.xml)
- [04_xquery_consultas.xml](04_xquery_consultas.xml)
- [05_transformacion.xml](05_transformacion.xml)
- [06_api_rest_admin.xml](06_api_rest_admin.xml)
- [07_frontend_xhtml.txt](07_frontend_xhtml.txt)
- [reporte.md](reporte.md)

## Conclusiones
1. El proyecto queda operativo en eXist-db tanto a nivel de consultas como de exposicion RESTXQ.
2. La publicacion del frontend queda estabilizada usando XHTML, evitando el problema de MIME observado con index.html.
3. La documentacion y los reportes quedan alineados con el estado final desplegado en la base.
