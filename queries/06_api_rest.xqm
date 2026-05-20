xquery version "3.1";

module namespace api="http://example.org/api";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace http="http://expath.org/ns/http-client";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare function api:cors-response($status as xs:integer) {
  <rest:response>
    <http:response status="{$status}">
      <http:header name="Access-Control-Allow-Origin" value="*"/>
      <http:header name="Access-Control-Allow-Methods" value="GET, OPTIONS"/>
      <http:header name="Access-Control-Allow-Headers" value="Authorization, Content-Type"/>
      <http:header name="Access-Control-Max-Age" value="86400"/>
    </http:response>
  </rest:response>
};

declare
  %rest:OPTIONS
  %rest:path("/proyecto-hr/empleados")
function api:empleados-options() {
  api:cors-response(204)
};

declare
  %rest:GET
  %rest:path("/proyecto-hr/empleados")
  %output:method("xml")
function api:empleados() {
  let $doc := doc("/db/proyecto-hr/xml/departamentos.xml")
  return
    (
      api:cors-response(200),
      <empleados>
        { $doc//empleado }
      </empleados>
    )
};