xquery version "3.1";

let $doc := doc("/db/proyecto-hr/xml/departamentos.xml")
let $departamentos := ($doc/hr/departamentos, $doc/departamentos)[1]
return
<empleados-filtrados>
{
  for $d in $departamentos/departamento
  for $e in $d/empleado
  where xs:decimal($e/salario) > 5000
  order by xs:decimal($e/salario) descending
  return
    <empleado>
      <departamento>{ data($d/@nombre) }</departamento>
      <id>{ data($e/@id) }</id>
      <nombre>{ data($e/nombre) }</nombre>
      <apellido>{ data($e/apellido) }</apellido>
      <salario>{ data($e/salario) }</salario>
    </empleado>
}
</empleados-filtrados>
