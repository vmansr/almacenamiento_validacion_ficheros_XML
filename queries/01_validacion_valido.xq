xquery version "3.1";

import module namespace validation="http://exist-db.org/xquery/validation";

let $xml := doc("/db/proyecto-hr/xml/departamentos.xml")
let $xsd := doc("/db/proyecto-hr/schema/departamentos.xsd")
return validation:jaxv-report(
  $xml,
  $xsd,
  xs:anyURI("http://www.w3.org/2001/XMLSchema")
)
