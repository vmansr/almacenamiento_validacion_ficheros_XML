# Proyecto XML HR con eXist-db

Proyecto de gestion de documentos XML usando eXist-db como base de datos XML nativa.

## Estructura
- data
- queries
- config
- app
- reports
- scripts

## Levantar eXist-db
```powershell
docker compose up -d
```

Acceso web:
- http://localhost:8081/exist

## Despliegue automatico a eXist-db
Este proyecto incluye un script que:
- crea colecciones necesarias,
- sube XML, XSD, XSL,
- publica consultas en /db/proyecto-hr/xquery,
- despliega modulo RESTXQ,
- publica frontend en /db/proyecto-hr/app,
- aplica collection.xconf para RESTXQ,
- ejecuta verificaciones basicas.

Ejecutar:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\deploy-exist.ps1
```

## Inicio rapido (dia siguiente / revision docente)
Para levantar todo en un solo paso (contenedor + espera de eXist-db + despliegue + apertura del frontend):

```powershell
powershell -ExecutionPolicy Bypass -File .\inicio-rapido.ps1
```

Si tambien quieres generar reporte de pruebas automaticamente:

```powershell
powershell -ExecutionPolicy Bypass -File .\inicio-rapido.ps1 -GenerarReporte
```

El script valida automaticamente:
- Docker instalado y disponible en PATH,
- Docker Desktop iniciado,
- eXist-db respondiendo en http://localhost:8081 antes de ejecutar el despliegue.

## Como ejecutar el programa
### Opcion recomendada (una sola linea)
1. Abrir Docker Desktop.
2. Ejecutar en la raiz del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File .\inicio-rapido.ps1
```

3. Abrir o verificar frontend en:
- http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260514b

### Opcion con reporte automatico
```powershell
powershell -ExecutionPolicy Bypass -File .\inicio-rapido.ps1 -GenerarReporte
```

### Opcion manual (paso a paso)
```powershell
docker compose up -d
powershell -ExecutionPolicy Bypass -File .\scripts\deploy-exist.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\generar-reporte-pruebas.ps1
```

### Cierre del entorno
```powershell
docker compose stop
```

## Validaciones esperadas
- Consulta valida: status valid.
- Consulta invalida: status invalid (por salario no decimal).
- Endpoint RESTXQ: GET http://localhost:8081/exist/restxq/proyecto-hr/empleados
- Frontend renderizable: http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml

## Recursos publicados en eXist-db
- Datos XML: /db/proyecto-hr/xml
- Esquema XSD: /db/proyecto-hr/schema
- XSLT: /db/proyecto-hr/xslt
- Consultas XQuery: /db/proyecto-hr/xquery
- Frontend: /db/proyecto-hr/app
- Modulo RESTXQ: /db/apps/proyecto-hr/modules/06_api_rest.xqm

## Frontend
- La interfaz del navegador debe abrirse desde index.xhtml y no desde index.html.
- Motivo: eXist-db almaceno index.html como recurso binario con MIME text/plain, por lo que el navegador mostraba el codigo fuente en lugar de renderizar la pagina.
- Solucion aplicada: se publico app/index.xhtml con Content-Type application/xhtml+xml y referencias absolutas a style.css y app.js.
- URL final recomendada: http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260514b

## Notas
- En la imagen actual de eXist-db el usuario admin inicia sin password.
- Si cambiaste el password de admin, ajusta variables en el script.
- El endpoint RESTXQ responde 401 sin autenticacion y 200 con admin en la configuracion actual.