# Memoria explicativa de las tareas realizadas

## 1. Datos generales
- Asignatura: Base de Datos Avanzadas
- Proyecto: victor_sanchez_bd_avanzadas
- Fecha de elaboracion: 2026-05-14
- Base de datos XML utilizada: eXist-db
- Entorno de ejecucion: Docker sobre Windows
- URL base REST de eXist-db: http://localhost:8081/exist/rest
- URL base RESTXQ: http://localhost:8081/exist/restxq
- Frontend final publicado: http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260514b

## 2. Objetivo de la memoria
Esta memoria tiene como finalidad documentar de manera completa el proceso seguido para desplegar, validar, depurar y dejar operativo un proyecto XML sobre eXist-db. Se describen las tareas realizadas, los problemas detectados, las correcciones aplicadas, los resultados obtenidos y la documentacion tecnica empleada como soporte.

## 3. Descripcion general del proyecto
El proyecto implementa un flujo de trabajo basado en tecnologias XML sobre eXist-db. El alcance funcional incluye:
- almacenamiento de documentos XML en una base de datos nativa XML,
- validacion de instancias XML contra un esquema XSD,
- consultas XPath y XQuery,
- transformacion XSLT,
- exposicion de datos mediante un endpoint RESTXQ,
- consumo del endpoint desde una interfaz web sencilla.

La estructura funcional definitiva del proyecto quedo organizada en las siguientes colecciones y recursos:
- /db/proyecto-hr/xml: documentos XML fuente.
- /db/proyecto-hr/schema: esquema XSD.
- /db/proyecto-hr/xslt: hoja de estilo XSLT.
- /db/proyecto-hr/xquery: consultas XQuery publicadas.
- /db/proyecto-hr/app: interfaz frontend publicada.
- /db/apps/proyecto-hr/modules: modulo RESTXQ.
- /db/system/config/db/apps/proyecto-hr/modules: configuracion collection.xconf para el trigger RESTXQ.

## 4. Entorno tecnico utilizado
### 4.1 Componentes principales
- Docker y Docker Compose para el levantamiento del contenedor.
- eXist-db como base de datos XML nativa.
- XQuery 3.1 para validacion, consultas y transformaciones.
- XPath para navegacion de nodos XML.
- XSLT para generacion de salida HTML.
- RESTXQ para publicacion de servicios HTTP declarativos en XQuery.
- HTML, CSS y JavaScript para la interfaz de consulta.
- PowerShell y curl para automatizacion de despliegue y pruebas.

### 4.2 Archivos clave del proyecto
- docker-compose.yml
- data/departamentos.xml
- data/departamentos_invalido.xml
- data/departamentos.xsd
- data/departamentos.xsl
- queries/01_validacion_valido.xq
- queries/02_validacion_invalido.xq
- queries/03_xpath_consultas.xq
- queries/04_xquery_consultas.xq
- queries/05_transformacion.xq
- queries/06_api_rest.xqm
- config/collection.xconf
- app/index.xhtml
- app/style.css
- app/app.js
- inicio-rapido.ps1
- scripts/deploy-exist.ps1
- scripts/generar-reporte-pruebas.ps1
- scripts/inicio-rapido.ps1

## 5. Situacion inicial y necesidades detectadas
Durante el trabajo practico se detectaron varias necesidades para dejar el proyecto funcional y presentable:
- revisar la sintaxis y la validez funcional de las consultas XQuery,
- desplegar correctamente los recursos XML, XSD y XSLT en eXist-db,
- publicar las consultas del proyecto en una coleccion accesible dentro de la base,
- exponer un endpoint RESTXQ de consulta de empleados,
- hacer funcional una interfaz web para consumir el endpoint,
- documentar las pruebas y el proceso de depuracion,
- corregir problemas reales de despliegue y acceso HTTP observados durante las pruebas.

## 6. Proceso seguido y tareas realizadas
### 6.1 Revision y restauracion de recursos del proyecto
Se revisaron los archivos del proyecto para confirmar que existieran en disco, que no estuvieran vacios y que su contenido fuese consistente. En esta etapa se verificaron tanto los archivos de datos como las consultas y recursos de configuracion.

Tareas realizadas:
- comprobacion de existencia y tamano de los archivos necesarios,
- revision de consultas XQuery y del modulo RESTXQ,
- consolidacion del conjunto de recursos necesarios para un despliegue repetible.

Resultado:
- todos los archivos necesarios quedaron identificados y listos para publicacion en eXist-db.

### 6.2 Creacion de colecciones en eXist-db
Inicialmente se intento crear colecciones mediante llamadas HTTP MKCOL. Sin embargo, en la imagen concreta de eXist-db utilizada durante la practica, este mecanismo devolvia HTTP 501. El despliegue solo avanzaba porque algunas colecciones ya existian.

Diagnostico:
- el metodo MKCOL no era fiable en el contenedor actual,
- el despliegue no era plenamente reproducible desde cero.

Correccion aplicada:
- se modifico el script scripts/deploy-exist.ps1 para sustituir MKCOL por xmldb:create-collection() ejecutado via XQuery,
- la nueva implementacion comprueba primero si la coleccion ya existe y, en caso contrario, la crea desde la propia base de datos.

Resultado:
- el despliegue completo quedo reproducible,
- desaparecieron los avisos HTTP 501,
- el script final pudo ejecutarse de principio a fin con validaciones satisfactorias.

### 6.3 Carga de datos XML, esquema XSD y hoja XSLT
Se publicaron los recursos base del proyecto en sus colecciones respectivas:
- departamentos.xml
- departamentos_invalido.xml
- departamentos.xsd
- departamentos.xsl

Ubicaciones finales:
- /db/proyecto-hr/xml/departamentos.xml
- /db/proyecto-hr/xml/departamentos_invalido.xml
- /db/proyecto-hr/schema/departamentos.xsd
- /db/proyecto-hr/xslt/departamentos.xsl

Resultado:
- los documentos necesarios para validar, consultar y transformar datos quedaron operativos dentro de la base.

### 6.4 Publicacion de consultas XQuery en la coleccion del proyecto
Se creo y poblo la coleccion /db/proyecto-hr/xquery con las consultas del proyecto:
- 01_validacion_valido.xq
- 02_validacion_invalido.xq
- 03_xpath_consultas.xq
- 04_xquery_consultas.xq
- 05_transformacion.xq
- 06_api_rest.xqm

Importancia de esta etapa:
- permite centralizar dentro de la base las consultas del proyecto,
- facilita su administracion desde eXide o por REST,
- deja evidencia clara de los recursos desplegados.

Resultado:
- todas las consultas quedaron almacenadas y listadas correctamente en eXist-db.

### 6.5 Configuracion y despliegue del modulo RESTXQ
Para publicar el servicio REST se utilizaron dos elementos fundamentales:
1. El archivo config/collection.xconf con el trigger RESTXQ.
2. El modulo queries/06_api_rest.xqm almacenado en /db/apps/proyecto-hr/modules.

Configuracion aplicada en collection.xconf:
- se habilito el trigger org.exist.extensions.exquery.restxq.impl.RestXqTrigger para la coleccion de modulos.

Modulo RESTXQ implementado:
- metodo GET sobre la ruta /proyecto-hr/empleados,
- retorno en XML,
- lectura del documento /db/proyecto-hr/xml/departamentos.xml,
- devolucion de los nodos empleado dentro del contenedor empleados,
- soporte adicional para cabeceras CORS y metodo OPTIONS.

Resultado:
- el endpoint RESTXQ quedo disponible en:
  http://localhost:8081/exist/restxq/proyecto-hr/empleados
- el endpoint respondio HTTP 401 sin autenticacion y HTTP 200 con admin.

### 6.6 Validacion XML contra XSD
Se ejecutaron pruebas de validacion explicita mediante el modulo validation de eXist-db, usando validation:jaxv-report().

Casos evaluados:
- XML valido: departamentos.xml
- XML invalido: departamentos_invalido.xml

Resultados observados:
- la consulta 01 devolvio status valid,
- la consulta 02 devolvio status invalid.

Interpretacion:
- la carga del XML y del XSD fue correcta,
- el mecanismo de validacion desde XQuery quedo operativo.

### 6.7 Ejecucion de consultas XPath y XQuery
Se verifico la ejecucion de las consultas analiticas del proyecto:
- 03_xpath_consultas.xq
- 04_xquery_consultas.xq

Resultados:
- 03_xpath_consultas.xq devolvio XML con consultas XPath sobre empleados,
- 04_xquery_consultas.xq devolvio XML filtrado y ordenado por salario.

Conclusion:
- la estructura del XML y las expresiones XPath/XQuery utilizadas son coherentes con el modelo de datos publicado.

### 6.8 Transformacion XSLT
La consulta 05_transformacion.xq aplico la hoja departamentos.xsl al documento departamentos.xml.

Resultado:
- se obtuvo salida HTML generada por XSLT,
- la transformacion se valido como correcta en el reporte final.

### 6.9 Publicacion y depuracion del frontend
La interfaz web se publico en la coleccion /db/proyecto-hr/app.

Archivos publicados:
- app.js
- style.css
- index.html
- posteriormente index.xhtml como version final operativa

Problemas detectados durante esta etapa:
1. index.html devolvia HTTP 400 al intentar subirse con un determinado MIME.
2. Cuando se conseguia almacenar, eXist-db lo sirvio como text/plain.
3. Como consecuencia, el navegador mostraba el codigo fuente HTML en pantalla en lugar de renderizar la pagina.
4. Al abrir la interfaz desde otro origen o puerto, la llamada al endpoint RESTXQ producia errores como 404 o Failed to fetch.
5. La ruta relativa hacia RESTXQ y el contexto de autenticacion del navegador generaban comportamiento inconsistente.

Correcciones aplicadas:
- se introdujo app/index.xhtml como recurso renderizable con MIME application/xhtml+xml,
- se ajustaron las referencias del frontend para usar rutas absolutas versionadas,
- se actualizo app.js para redirigir al frontend correcto servido desde eXist,
- se incorporo logica para detectar respuestas HTML incorrectas en lugar de XML,
- se dejo la URL final recomendada en index.xhtml.

Resultado:
- el frontend final operativo quedo publicado en:
  http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260514b
- la cabecera HTTP validada para este recurso fue application/xhtml+xml.

### 6.10 Automatizacion de despliegue y generacion de reportes
Se consolidaron dos scripts de apoyo:
- scripts/deploy-exist.ps1
- scripts/generar-reporte-pruebas.ps1

Funciones del script de despliegue:
- verifica archivos locales,
- crea colecciones con xmldb:create-collection,
- sube XML, XSD, XSL, consultas XQuery y frontend,
- aplica collection.xconf,
- despliega el modulo RESTXQ,
- ejecuta validaciones rapidas del sistema.

Funciones del script de reportes:
- ejecuta las consultas de prueba,
- almacena evidencias crudas,
- genera reporte.md,
- genera informe_academico.md,
- verifica especificamente la publicacion de index.xhtml.

Resultado:
- el proyecto dispone de automatizacion reproducible y documentacion generada automaticamente.

### 6.11 Inicio diario y apertura para revision docente
Como resultado final se incorporo un flujo de arranque rapido para uso diario y para revision por parte del profesor:
- inicio-rapido.ps1 en la raiz del proyecto (lanzador simple),
- scripts/inicio-rapido.ps1 con la logica completa de arranque.

Flujo implementado en scripts/inicio-rapido.ps1:
1. Verifica que Docker este instalado y disponible.
2. Verifica que Docker Desktop este iniciado.
3. Ejecuta docker compose up -d.
4. Espera activamente hasta que eXist-db responda por HTTP.
5. Ejecuta scripts/deploy-exist.ps1.
6. Opcionalmente ejecuta scripts/generar-reporte-pruebas.ps1 con el parametro -GenerarReporte.
7. Abre automaticamente el frontend final en el navegador.

Comando recomendado de ejecucion:
- powershell -ExecutionPolicy Bypass -File .\inicio-rapido.ps1

Comando con reporte automatico:
- powershell -ExecutionPolicy Bypass -File .\inicio-rapido.ps1 -GenerarReporte

Comando de cierre del entorno:
- docker compose stop

## 7. Incidencias tecnicas relevantes y resolucion
### 7.1 HTTP 400 al subir index.html
- Causa: incompatibilidad practica del tipo de recurso y del tratamiento MIME por eXist-db.
- Resolucion: sustituir la pagina principal por index.xhtml y publicarla con application/xhtml+xml.

### 7.2 Visualizacion del codigo fuente HTML en el navegador
- Causa: index.html se sirvio como text/plain.
- Resolucion: publicar y consumir index.xhtml como recurso final renderizable.

### 7.3 Error HTTP 404 al consultar empleados desde el navegador
- Causa: uso de rutas relativas y apertura de la app desde un origen distinto al de eXist-db.
- Resolucion: redirigir el acceso al frontend publicado en eXist y ajustar la resolucion del endpoint RESTXQ.

### 7.4 Error Failed to fetch
- Causa: mezcla de autenticacion, CORS y origen distinto.
- Resolucion: servir el frontend desde eXist, ajustar la logica del cliente y añadir cabeceras CORS en el modulo RESTXQ.

### 7.5 HTTP 501 al crear colecciones
- Causa: la imagen usada de eXist-db no aceptaba MKCOL como se esperaba.
- Resolucion: reescribir la creacion de colecciones usando xmldb:create-collection().

### 7.6 Error curl 52 en arranque rapido
- Causa: el despliegue iniciaba inmediatamente despues de levantar el contenedor y eXist-db aun no estaba listo para responder.
- Resolucion: se agrego espera activa por disponibilidad HTTP en scripts/inicio-rapido.ps1 antes de ejecutar el despliegue.

## 8. Resultados finales obtenidos
Los resultados finales consolidados en el reporte fueron los siguientes:

| Prueba | Tipo | Estado | Resultado observado |
|---|---|---|---|
| 01_validacion_valido | XQuery | ok | Se obtuvo estado valid |
| 02_validacion_invalido | XQuery | ok | Se obtuvo estado invalid |
| 03_xpath_consultas | XQuery | ok | Se obtuvo XML con consultas XPath sobre empleados |
| 04_xquery_consultas | XQuery | ok | Se obtuvo XML filtrado y ordenado por salario |
| 05_transformacion | XQuery | ok | Se obtuvo salida HTML generada por XSLT |
| 06_api_rest | RESTXQ | ok | Sin auth=401; con auth=200 |
| 07_frontend_xhtml | Frontend | ok | index.xhtml publicado en /db/proyecto-hr/app; index.html quedo como text/plain |

Conclusion tecnica:
- el sistema quedo funcional en todas sus capas: almacenamiento, validacion, consulta, transformacion, API y cliente web.

## 9. Evidencias generadas
La ejecucion final genero las siguientes evidencias en la carpeta de reportes:
- 01_validacion_valido.xml
- 02_validacion_invalido.xml
- 03_xpath_consultas.xml
- 04_xquery_consultas.xml
- 05_transformacion.xml
- 06_api_rest_admin.xml
- 07_frontend_xhtml.txt
- reporte.md
- informe_academico.md

Estas evidencias respaldan los resultados funcionales obtenidos y pueden adjuntarse como anexo tecnico de la entrega.

## 10. Capturas del proceso seguido y resultados obtenidos
Nota importante:
- En este entorno de trabajo no se generaron capturas de pantalla automaticas desde el navegador.
- A continuacion se deja una guia detallada de capturas recomendadas para insertar manualmente en la memoria final.
- Cada captura puede obtenerse desde el navegador, eXide, la consola PowerShell o la interfaz web de eXist-db.

### Captura 1. Contenedor eXist-db en ejecucion
Objetivo:
- evidenciar que el entorno Docker esta levantado.

Sugerencia de contenido:
- salida del comando docker compose up -d o docker compose restart,
- interfaz de contenedores si se usa Docker Desktop.

Pie de figura sugerido:
- "Contenedor eXist-db operativo en Docker antes del despliegue de recursos".

### Captura 2. Colecciones creadas en eXist-db
Objetivo:
- mostrar la estructura creada dentro de la base.

Colecciones a mostrar:
- /db/proyecto-hr/xml
- /db/proyecto-hr/schema
- /db/proyecto-hr/xslt
- /db/proyecto-hr/xquery
- /db/proyecto-hr/app
- /db/apps/proyecto-hr/modules

Pie de figura sugerido:
- "Colecciones del proyecto publicadas en eXist-db".

### Captura 3. Recursos XQuery cargados en /db/proyecto-hr/xquery
Objetivo:
- evidenciar que las consultas 01 a 06 fueron publicadas.

Pie de figura sugerido:
- "Consultas XQuery almacenadas en la coleccion /db/proyecto-hr/xquery".

### Captura 4. Configuracion RESTXQ
Objetivo:
- mostrar el archivo collection.xconf o su efecto en la coleccion de modulos.

Pie de figura sugerido:
- "Activacion del trigger RESTXQ mediante collection.xconf".

### Captura 5. Respuesta de validacion XML valida
Objetivo:
- mostrar el contenido de 01_validacion_valido.xml.

Pie de figura sugerido:
- "Resultado de la validacion del documento XML valido contra el esquema XSD".

### Captura 6. Respuesta de validacion XML invalida
Objetivo:
- mostrar el contenido de 02_validacion_invalido.xml.

Pie de figura sugerido:
- "Resultado de la validacion del documento XML invalido con deteccion de errores de esquema".

### Captura 7. Consulta XPath ejecutada
Objetivo:
- evidenciar la salida de 03_xpath_consultas.xml.

Pie de figura sugerido:
- "Resultado de las consultas XPath sobre el documento de empleados".

### Captura 8. Consulta XQuery ejecutada
Objetivo:
- evidenciar la salida de 04_xquery_consultas.xml.

Pie de figura sugerido:
- "Resultado de la consulta XQuery con filtrado y ordenacion por salario".

### Captura 9. Transformacion XSLT
Objetivo:
- mostrar la salida HTML generada por 05_transformacion.xml.

Pie de figura sugerido:
- "Transformacion XSLT del documento XML de departamentos".

### Captura 10. Endpoint RESTXQ operativo
Objetivo:
- mostrar la respuesta XML del endpoint /exist/restxq/proyecto-hr/empleados.

Pie de figura sugerido:
- "Respuesta del servicio RESTXQ de consulta de empleados".

### Captura 11. Problema detectado con index.html
Objetivo:
- documentar el problema de MIME que hacia que el navegador mostrara el codigo fuente.

Contenido recomendado:
- apertura de index.html donde se vea el HTML como texto,
- o la cabecera HTTP text/plain asociada al recurso.

Pie de figura sugerido:
- "Incidencia detectada: index.html servido como text/plain en eXist-db".

### Captura 12. Solucion final con index.xhtml
Objetivo:
- mostrar el frontend funcionando correctamente.

URL recomendada:
- http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260514b

Pie de figura sugerido:
- "Interfaz final renderizada correctamente desde eXist-db con consumo del endpoint RESTXQ".

### Captura 13. Ejecucion del script de despliegue corregido
Objetivo:
- evidenciar el despliegue reproducible sin errores 501.

Pie de figura sugerido:
- "Ejecucion satisfactoria del script deploy-exist.ps1 tras la correccion de creacion de colecciones".

### Captura 14. Generacion del reporte final
Objetivo:
- mostrar la ejecucion del script generar-reporte-pruebas.ps1 y la generacion de la carpeta reports.

Pie de figura sugerido:
- "Generacion automatizada del reporte tecnico y del informe academico".

## 11. Documentacion empleada
Las siguientes referencias fueron utilizadas como base tecnica para la solucion del proyecto:

1. eXist-db Documentation. XQuery in eXist-db.
   URL: https://exist-db.org/exist/apps/doc/xquery
   Utilidad en el proyecto:
   - confirmacion del soporte de XQuery 3.1,
   - uso de modulos XQuery,
   - serializacion y comportamiento HTTP,
   - recomendaciones sobre modulos y RESTXQ.

2. eXist-db Documentation. The xmldb module.
   URL: https://exist-db.org/exist/apps/doc/xmldb
   Utilidad en el proyecto:
   - uso de xmldb:create-collection(),
   - comprension de la manipulacion de colecciones y recursos dentro de la base,
   - soporte para corregir el problema observado con MKCOL y HTTP 501.

3. eXist-db Documentation. XML Validation.
   URL: https://exist-db.org/exist/apps/doc/validation
   Utilidad en el proyecto:
   - validacion explicita de XML mediante funciones del modulo validation,
   - uso de validation:jaxv-report(),
   - interpretacion de los reportes valid e invalid.

4. eXist-db Documentation. Community Specifications / RESTXQ en XQuery in eXist-db.
   URL: https://exist-db.org/exist/apps/doc/xquery
   Utilidad en el proyecto:
   - habilitacion del trigger RESTXQ en collection.xconf,
   - despliegue de modulos XQuery anotados con RESTXQ,
   - comprension del comportamiento de servicios HTTP declarados en XQuery.

5. W3C. XQuery 3.1: An XML Query Language.
   URL: https://www.w3.org/TR/xquery/
   Utilidad en el proyecto:
   - referencia conceptual del lenguaje usado en las consultas.

6. W3C. XSLT and XQuery Serialization 3.1.
   URL: https://www.w3.org/TR/xslt-xquery-serialization-31/
   Utilidad en el proyecto:
   - referencia para la salida XML/XHTML/HTML y serializacion en contexto HTTP.

7. EXQuery RESTXQ Specification.
   URL: http://exquery.github.io/exquery/exquery-restxq-specification/restxq-1.0-specification.html
   Utilidad en el proyecto:
   - base conceptual de las anotaciones RESTXQ utilizadas en el modulo 06_api_rest.xqm.

8. EXPath HTTP Client Specification.
   URL: http://expath.org/spec/http-client
   Utilidad en el proyecto:
   - referencia del espacio de nombres HTTP usado en la construccion de respuestas RESTXQ con cabeceras personalizadas.

## 12. Relacion entre documentacion y solucion aplicada
La documentacion no se empleo solo como consulta teorica, sino como guia directa para la implementacion:
- la documentacion del modulo xmldb permitio reemplazar el mecanismo MKCOL por una solucion propia de eXist-db,
- la documentacion de validation justifico el uso de jaxv-report para las pruebas de conformidad XML/XSD,
- la documentacion de XQuery y RESTXQ permitio estructurar el modulo API, las anotaciones de ruta y la serializacion XML,
- la documentacion sobre RESTXQ y collection.xconf explico por que era necesario activar el trigger solo en la jerarquia que contiene los modulos REST,
- las referencias de serializacion fueron utiles para entender el problema de representacion del frontend y la conveniencia de publicar index.xhtml.

## 13. Conclusiones finales
1. El proyecto quedo completamente operativo dentro de eXist-db.
2. Se validaron satisfactoriamente los flujos de almacenamiento, validacion, consulta, transformacion y exposicion de datos.
3. Se resolvieron incidencias reales de despliegue HTTP, autenticacion, CORS, rutas relativas y tipos MIME.
4. El frontend quedo estabilizado usando index.xhtml como recurso principal renderizable.
5. El despliegue final es reproducible gracias a la correccion del script de creacion de colecciones.
6. La documentacion generada permite defender tecnicamente el trabajo realizado y justificar cada decision aplicada.

## 14. Anexos recomendados para la entrega
Se recomienda adjuntar junto con esta memoria los siguientes archivos:
- reporte.md
- informe_academico.md
- 01_validacion_valido.xml
- 02_validacion_invalido.xml
- 03_xpath_consultas.xml
- 04_xquery_consultas.xml
- 05_transformacion.xml
- 06_api_rest_admin.xml
- 07_frontend_xhtml.txt

Con ello se dispone de una entrega completa compuesta por:
- memoria explicativa,
- informe academico,
- reporte tecnico,
- evidencias de ejecucion,
- recursos desplegados y scripts reproducibles.
