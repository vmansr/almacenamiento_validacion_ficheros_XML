# Informe academico de pruebas

## Datos generales
- Asignatura: Base de Datos Avanzadas
- Proyecto: proyecto-eXistdb-xml-hr
- Fecha de ejecucion: 2026-05-13 22:50:38
- Entorno: eXist-db en contenedor Docker
- Endpoint base REST: http://localhost:8081/exist/rest
- Endpoint base RESTXQ: http://localhost:8081/exist/restxq

## Objetivo
Validar que el proyecto XML/XQuery funciona de forma integral en eXist-db, cubriendo:
- validacion de XML contra XSD,
- consultas XPath y XQuery,
- transformacion XSLT,
- exposicion de datos mediante API RESTXQ.

## Metodologia
1. Se desplegaron recursos XML, XSD, XSL y modulo RESTXQ en colecciones de eXist-db.
2. Se ejecutaron 6 pruebas automatizadas mediante script de verificacion.
3. Se almacenaron evidencias crudas por prueba en archivos XML.
4. Se validaron cambios posteriores de publicacion de consultas en la coleccion /db/proyecto-hr/xquery.

## Criterios de aceptacion
- 01_validacion_valido debe devolver estado valid.
- 02_validacion_invalido debe devolver estado invalid.
- 03_xpath_consultas debe devolver resultados XML con empleados, emails y filtro por departamento.
- 04_xquery_consultas debe devolver empleados con salario > 5000 ordenados descendentemente.
- 05_transformacion debe devolver salida HTML desde XSLT.
- 06_api_rest debe responder correctamente via RESTXQ con autenticacion de administrador.

## Resultados
| Prueba | Tipo | Estado | Resultado observado |
|---|---|---|---|
| 01_validacion_valido | XQuery | ok | Se obtuvo estado valid |
| 02_validacion_invalido | XQuery | ok | Se obtuvo estado invalid |
| 03_xpath_consultas | XQuery | ok | Se obtuvo XML de resultados con rutas XPath solicitadas |
| 04_xquery_consultas | XQuery | ok | Se obtuvo XML filtrado y ordenado por salario |
| 05_transformacion | XQuery/XSLT | ok | Se obtuvo salida HTML transformada |
| 06_api_rest | RESTXQ | ok | Sin auth: 401, con auth admin: 200 |

## Cambios efectuados posteriormente
1. Se creo la coleccion /db/proyecto-hr/xquery para almacenar consultas XQuery del proyecto.
2. Se publicaron 01_validacion_valido.xq y 02_validacion_invalido.xq en dicha coleccion.
3. Se ejecuto cada recurso directamente por URL REST de eXist con respuesta HTTP 200.
4. Confirmacion funcional:
- 01_validacion_valido.xq devolvio status valid.
- 02_validacion_invalido.xq devolvio status invalid.

## Evidencias
- [01_validacion_valido.xml](01_validacion_valido.xml)
- [02_validacion_invalido.xml](02_validacion_invalido.xml)
- [03_xpath_consultas.xml](03_xpath_consultas.xml)
- [04_xquery_consultas.xml](04_xquery_consultas.xml)
- [05_transformacion.xml](05_transformacion.xml)
- [06_api_rest_admin.xml](06_api_rest_admin.xml)
- [reporte.md](reporte.md)

## Conclusiones
1. El sistema cumple los objetivos funcionales definidos para esta fase.
2. El pipeline XML (almacenamiento, validacion, consulta, transformacion y publicacion) esta operativo.
3. Los cambios posteriores en /db/proyecto-hr/xquery quedaron validados y documentados.
