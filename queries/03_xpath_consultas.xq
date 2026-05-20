xquery version "3.1";

let $doc := doc("/db/proyecto-hr/xml/departamentos.xml")
let $departamentos := ($doc/hr/departamentos, $doc/departamentos)[1]
return
<resultados>
  <todos-los-empleados>{ $departamentos//empleado }</todos-los-empleados>
  <emails>{ $departamentos//empleado/email/text() }</emails>
  <empleados-administracion>{ $departamentos/departamento[@id="10"]/empleado }</empleados-administracion>
</resultados>
