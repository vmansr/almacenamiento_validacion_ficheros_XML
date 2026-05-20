# Proyecto XML HR con eXist-db

Implementacion de un flujo completo de gestion de documentos XML sobre eXist-db como base de datos XML nativa. Incluye modelado XML con esquema HR, validacion XSD, consultas XPath y XQuery, transformacion XSLT, endpoint RESTXQ e interfaz web.

## Requisitos previos
Antes de ejecutar el proyecto, asegurate de tener instalado:

| Herramienta | Version recomendada | Descarga |
|---|---|---|
| Docker Desktop | 4.x o superior | https://www.docker.com/products/docker-desktop |
| Git | cualquier version reciente | https://git-scm.com |
| PowerShell | 5.1 o superior (incluido en Windows 10/11) | preinstalado |

> No se requiere instalar eXist-db manualmente. El contenedor Docker lo gestiona automaticamente.

## Estructura del proyecto
```
proyecto-eXistdb-xml-hr/
├── data/           # Documentos XML, XSD y XSLT
├── queries/        # Consultas XQuery (validacion, XPath, FLWOR, transformacion, RESTXQ)
├── config/         # Configuracion de colecciones eXist-db (collection.xconf)
├── app/            # Frontend web (XHTML, CSS, JavaScript)
├── scripts/        # Scripts de despliegue y generacion de reportes
├── reports/        # Evidencias XML de consultas ejecutadas
├── docker-compose.yml
└── inicio-rapido.ps1
```

## Ejecucion rapida (opcion recomendada)

```powershell
# 1. Clona el repositorio
git clone https://github.com/vmansr/almacenamiento_validacion_ficheros_XML.git
cd almacenamiento_validacion_ficheros_XML

# 2. Abre Docker Desktop y espera que este corriendo

# 3. Ejecuta el script de inicio (levanta Docker + despliega todo + abre el navegador)
powershell -ExecutionPolicy Bypass -File .\inicio-rapido.ps1
```

El script espera automaticamente a que eXist-db este listo antes de desplegar. Al finalizar, el navegador se abre directamente en la interfaz del proyecto.

**URL de la aplicacion:** http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml

---

## Levantar eXist-db (manual)
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

## Inicio rapido
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
- http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260519c

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
- URL final recomendada: http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260519c

## Credenciales de acceso
La configuracion por defecto de eXist-db en este proyecto es:
```
Usuario: admin
Contraseña: (vacía - solo presiona ENTER)
```

Para acceder a la consola de administracion:
1. Abre http://localhost:8081/exist/apps/eXist-db/admin
2. Escribe: `admin`
3. Contraseña: presiona ENTER sin escribir nada

## Notas
- En la imagen actual de eXist-db el usuario admin inicia **sin password**.
- Si cambiaste el password de admin, ajusta la variable `$Password` en los scripts (`deploy-exist.ps1`, `generar-reporte-pruebas.ps1`).
- El endpoint RESTXQ responde 401 sin autenticacion y 200 con credenciales admin en la configuracion actual.
- Los scripts usan autenticacion HTTP Basic con usuario admin y contraseña vacía por defecto.
