xquery version "3.1";

import module namespace transform="http://exist-db.org/xquery/transform";

let $xml := doc("/db/proyecto-hr/xml/departamentos.xml")
let $xsl := doc("/db/proyecto-hr/xslt/departamentos.xsl")
return transform:transform($xml, $xsl, ())
