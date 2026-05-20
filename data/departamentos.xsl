<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <html>
      <head>
        <title>Departamentos y empleados</title>
      </head>
      <body>
        <h1>Departamentos y empleados del esquema HR</h1>
        <table border="1">
          <tr>
            <th>ID Departamento</th>
            <th>Departamento</th>
            <th>ID Empleado</th>
            <th>Nombre</th>
            <th>Apellido</th>
            <th>Email</th>
            <th>Salario</th>
            <th>Cargo</th>
          </tr>
          <xsl:for-each select="hr/departamentos/departamento | departamentos/departamento">
            <xsl:variable name="depId" select="@id"/>
            <xsl:variable name="depNombre" select="@nombre"/>
            <xsl:for-each select="empleado">
              <tr>
                <td><xsl:value-of select="$depId"/></td>
                <td><xsl:value-of select="$depNombre"/></td>
                <td><xsl:value-of select="@id"/></td>
                <td><xsl:value-of select="nombre"/></td>
                <td><xsl:value-of select="apellido"/></td>
                <td><xsl:value-of select="email"/></td>
                <td><xsl:value-of select="salario"/></td>
                <td><xsl:value-of select="cargo"/></td>
              </tr>
            </xsl:for-each>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
