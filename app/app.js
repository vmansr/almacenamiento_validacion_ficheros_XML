const salida = document.getElementById('salida');
const boton = document.getElementById('btnEmpleados');
const botonEsquema = document.getElementById('btnEsquema');
const botonCopiar = document.getElementById('btnCopiar');
const botonPresentacion = document.getElementById('btnPresentacion');
const schemaView = document.getElementById('schemaView');
const EXIST_APP_URL = 'http://localhost:8081/exist/rest/db/proyecto-hr/app/index.xhtml?v=20260519c';
const RESTXQ_URL = 'http://localhost:8081/exist/restxq/proyecto-hr/empleados';
const RESTXQ_PATH = '/exist/restxq/proyecto-hr/empleados';
const SCHEMA_URL = 'http://localhost:8081/exist/rest/db/proyecto-hr/xquery/07_esquema_hr_completo.xq';
const SCHEMA_PATH = '/exist/rest/db/proyecto-hr/xquery/07_esquema_hr_completo.xq';
const AUTH_HEADER = 'Basic YWRtaW46';

function isServedFromExistApp() {
  return window.location.origin === 'http://localhost:8081' && window.location.pathname.startsWith('/exist/rest/db/proyecto-hr/app/');
}

function getRestXqUrl() {
  if (window.location.origin === 'http://localhost:8081') {
    return `${window.location.origin}${RESTXQ_PATH}`;
  }

  return RESTXQ_URL;
}

function getSchemaUrl() {
  if (window.location.origin === 'http://localhost:8081') {
    return `${window.location.origin}${SCHEMA_PATH}`;
  }

  return SCHEMA_URL;
}

async function fetchEmpleados(url) {
  const firstTry = await fetch(url);
  if (firstTry.status !== 401) {
    return firstTry;
  }

  // Fallback for default classroom setup where admin has empty password.
  return fetch(url, {
    headers: {
      Authorization: AUTH_HEADER
    }
  });
}

function escapeHtml(str) {
  return str
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

function setPlainOutput(text) {
  schemaView.classList.add('hidden');
  salida.classList.remove('hidden');
  salida.textContent = text;
}

function getCurrentOutputText() {
  if (!schemaView.classList.contains('hidden')) {
    return schemaView.textContent.trim();
  }
  return salida.textContent.trim();
}

async function copyOutputToClipboard() {
  const text = getCurrentOutputText();
  if (!text) {
    return false;
  }

  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch (_e) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    const ok = document.execCommand('copy');
    document.body.removeChild(textArea);
    return ok;
  }
}

function renderSchema(xmlText) {
  const parser = new DOMParser();
  const doc = parser.parseFromString(xmlText, 'application/xml');

  if (doc.querySelector('parsererror')) {
    setPlainOutput(xmlText);
    return;
  }

  const read = (tag) => doc.querySelector(tag)?.textContent?.trim() || '-';
  const xsdNode = doc.querySelector('estructura-xsd');
  const dataNode = doc.querySelector('datos-hr');

  const serializer = new XMLSerializer();
  const xsdText = xsdNode ? serializer.serializeToString(xsdNode) : 'Sin bloque XSD';
  const dataText = dataNode ? serializer.serializeToString(dataNode) : 'Sin bloque de datos';

  schemaView.innerHTML = `
    <div class="schema-cards">
      <div class="schema-card"><span class="label">Raiz</span><span class="value">${escapeHtml(read('raiz'))}</span></div>
      <div class="schema-card"><span class="label">Regiones</span><span class="value">${escapeHtml(read('total-regiones'))}</span></div>
      <div class="schema-card"><span class="label">Paises</span><span class="value">${escapeHtml(read('total-paises'))}</span></div>
      <div class="schema-card"><span class="label">Ubicaciones</span><span class="value">${escapeHtml(read('total-ubicaciones'))}</span></div>
      <div class="schema-card"><span class="label">Departamentos</span><span class="value">${escapeHtml(read('total-departamentos'))}</span></div>
      <div class="schema-card"><span class="label">Empleados</span><span class="value">${escapeHtml(read('total-empleados'))}</span></div>
    </div>
    <details>
      <summary>Estructura XSD</summary>
      <pre class="schema-xml">${escapeHtml(xsdText)}</pre>
    </details>
    <details open="open">
      <summary>Datos HR actuales</summary>
      <pre class="schema-xml">${escapeHtml(dataText)}</pre>
    </details>
  `;

  salida.classList.add('hidden');
  schemaView.classList.remove('hidden');
}

boton.addEventListener('click', async () => {
  try {
    if (!isServedFromExistApp()) {
      setPlainOutput(`Redirigiendo a eXist-db: ${EXIST_APP_URL}`);
      window.location.href = EXIST_APP_URL;
      return;
    }

    const res = await fetchEmpleados(getRestXqUrl());
    if (!res.ok) {
      throw new Error('HTTP ' + res.status);
    }

    const contentType = (res.headers.get('content-type') || '').toLowerCase();
    const text = await res.text();

    if (contentType.includes('text/html') || text.trimStart().startsWith('<!DOCTYPE html>')) {
      setPlainOutput(
        'Se recibio HTML en lugar de XML. Abre la app en: ' + EXIST_APP_URL
      );
      return;
    }

    setPlainOutput(text);
  } catch (e) {
    setPlainOutput(
      'Error al consultar: ' + e.message +
      '. Verifica que eXist-db este activo en http://localhost:8081.'
    );
  }
});

botonEsquema.addEventListener('click', async () => {
  try {
    if (!isServedFromExistApp()) {
      setPlainOutput(`Redirigiendo a eXist-db: ${EXIST_APP_URL}`);
      window.location.href = EXIST_APP_URL;
      return;
    }

    const res = await fetchEmpleados(getSchemaUrl());
    if (!res.ok) {
      throw new Error('HTTP ' + res.status);
    }

    const text = await res.text();
    renderSchema(text);
  } catch (e) {
    setPlainOutput(
      'Error al consultar esquema HR: ' + e.message +
      '. Verifica que eXist-db este activo en http://localhost:8081.'
    );
  }
});

botonCopiar.addEventListener('click', async () => {
  const copied = await copyOutputToClipboard();
  if (copied) {
    setPlainOutput('Salida copiada al portapapeles.');
  } else {
    setPlainOutput('No se pudo copiar la salida.');
  }
});

botonPresentacion.addEventListener('click', () => {
  const active = document.body.classList.toggle('present-mode');
  botonPresentacion.textContent = active ? 'Modo normal' : 'Modo presentacion';
});