xquery version "3.1";

let $xml := doc("/db/proyecto-hr/xml/departamentos.xml")
let $xsd := doc("/db/proyecto-hr/schema/departamentos.xsd")

return
<esquema-hr-completo>
  <resumen>
    <raiz>{ name($xml/*[1]) }</raiz>
    <total-regiones>{ count($xml/hr/regiones/region) }</total-regiones>
    <total-paises>{ count($xml/hr/paises/pais) }</total-paises>
    <total-ubicaciones>{ count($xml/hr/ubicaciones/ubicacion) }</total-ubicaciones>
    <total-departamentos>{ count($xml/hr/departamentos/departamento) }</total-departamentos>
    <total-empleados>{ count($xml/hr/departamentos/departamento/empleado) }</total-empleados>
  </resumen>
  <estructura-xsd>{ $xsd/xs:schema }</estructura-xsd>
  <datos-hr>{ $xml/hr }</datos-hr>
</esquema-hr-completo>
