<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:fn="http://270a.info/xpath-function/"
    >

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:template name="langTextNode">
        <xsl:if test="@xml:lang">
            <xsl:copy-of select="@*[name() = 'xml:lang']"/>
        </xsl:if>
        <xsl:value-of select="text()"/>
    </xsl:template>

    <xsl:template name="getAttributeValue">
        <xsl:param name="attributeName"/>

        <xsl:if test="$attributeName">
            <xsl:value-of select="$attributeName"/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
