# Informe academico de pruebas

## Datos generales
- Asignatura: Base de Datos Avanzadas
- Proyecto: proyecto-eXistdb-xml-hr
- Fecha de ejecucion: 2026-05-13 22:26:50
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
4. Se clasifico cada prueba como ok o revisar segun criterios esperados.

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

## Evidencias
- [01_validacion_valido.xml](01_validacion_valido.xml)
- [02_validacion_invalido.xml](02_validacion_invalido.xml)
- [03_xpath_consultas.xml](03_xpath_consultas.xml)
- [04_xquery_consultas.xml](04_xquery_consultas.xml)
- [05_transformacion.xml](05_transformacion.xml)
- [06_api_rest_admin.xml](06_api_rest_admin.xml)
- [reporte.md](reporte.md)

## Cambios efectuados posteriormente
1. Se creo la coleccion /db/proyecto-hr/xquery para almacenar consultas XQuery del proyecto.
2. Se publicaron en dicha coleccion los recursos 01_validacion_valido.xq y 02_validacion_invalido.xq.
3. Se ejecuto cada recurso directamente por REST de eXist con respuesta HTTP 200.
4. Resultado confirmado:
- 01_validacion_valido.xq: status valid.
- 02_validacion_invalido.xq: status invalid.

## Analisis tecnico breve
- La validacion positiva y negativa confirma que el XSD se aplica correctamente y discrimina datos invalidos.
- Las consultas XPath/XQuery evidencian acceso y transformacion de datos XML conforme a reglas de negocio basicas.
- La transformacion XSLT valida la capa de presentacion basada en XML.
- El endpoint RESTXQ requiere autenticacion; esto es consistente con una configuracion segura del servicio.

## Conclusiones
1. El sistema cumple los objetivos funcionales definidos para esta fase.
2. El pipeline de datos XML (almacenamiento, validacion, consulta, transformacion y publicacion) esta operativo.
3. La evidencia generada permite trazabilidad y reproducibilidad de las pruebas.

## Recomendaciones
1. Mantener el script de despliegue y el script de pruebas como paso obligatorio antes de cada entrega.
2. Documentar credenciales y politica de acceso del endpoint RESTXQ en la guia de uso.
3. Agregar casos de prueba adicionales con mayor volumen de datos y escenarios de error controlados.
