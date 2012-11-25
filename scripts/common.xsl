<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:fn="http://270a.info/xpath-function/"
    >

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:variable name="pathToConfig"><xsl:text>./config.rdf</xsl:text></xsl:variable>
    <xsl:variable name="rdf" select="fn:getConfig('rdf')"/>
    <xsl:variable name="xsd" select="fn:getConfig('xsd')"/>
    <xsl:variable name="qb" select="fn:getConfig('qb')"/>
    <xsl:variable name="skos" select="fn:getConfig('skos')"/>
    <xsl:variable name="sdmx" select="fn:getConfig('sdmx')"/>
    <xsl:variable name="lang" select="fn:getConfig('lang')"/>
    <xsl:variable name="baseuri" select="fn:getConfig('baseuri')"/>
    <xsl:variable name="concept" select="fn:getConfig('concept')"/>
    <xsl:variable name="code" select="fn:getConfig('code')"/>
    <xsl:variable name="property" select="fn:getConfig('property')"/>
    <xsl:variable name="dataset" select="fn:getConfig('dataset')"/>
    <xsl:variable name="slice" select="fn:getConfig('slice')"/>
    <xsl:variable name="uriThingSeperator" select="fn:getConfig('uriThingSeperator')"/>
    <xsl:variable name="uriDimensionSeperator" select="fn:getConfig('uriDimensionSeperator')"/>

    <xsl:template name="langTextNode">
        <xsl:if test="@xml:lang">
            <xsl:copy-of select="@*[name() = 'xml:lang']"/>
        </xsl:if>
        <xsl:value-of select="text()"/>
    </xsl:template>

    <xsl:function name="fn:getAttributeValue">
        <xsl:param name="attributeName"/>

        <xsl:if test="$attributeName">
            <xsl:value-of select="$attributeName"/>
        </xsl:if>
    </xsl:function>

    <xsl:template name="datatype-dateTime">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://www.w3.org/2001/XMLSchema#dateTime</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-date">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-xsd-decimal">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://www.w3.org/2001/XMLSchema#decimal</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-xsd-double">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://www.w3.org/2001/XMLSchema#double</xsl:text>
        </xsl:attribute>
    </xsl:template>


    <xsl:function name="fn:getSDMXCodeListURI">
        <xsl:param name="CodeList"/>

        <xsl:choose>
            <xsl:when test="$CodeList = 'CL_CURRENCY'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#currency</xsl:text>
            </xsl:when>
            <xsl:when test="$CodeList = 'CL_AREA'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#area</xsl:text>
            </xsl:when>
            <xsl:when test="$CodeList = 'CL_DECIMALS'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#decimals</xsl:text>
            </xsl:when>
            <xsl:when test="$CodeList = 'CL_FREQ'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#freq</xsl:text>
            </xsl:when>
            <xsl:when test="$CodeList = 'CL_CONF_STATUS'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#confStatus</xsl:text>
            </xsl:when>
            <xsl:when test="$CodeList = 'CL_OBS_STATUS'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#obsStatus</xsl:text>
            </xsl:when>
            <xsl:when test="$CodeList = 'CL_SEX'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#sex</xsl:text>
            </xsl:when>
            <xsl:when test="$CodeList = 'CL_TIME_FORMAT'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#timeFormat</xsl:text>
            </xsl:when>
            <xsl:when test="$CodeList = 'CL_UNIT_MULT'">
                <xsl:text>http://purl.org/linked-data/sdmx/2009/code#unitMult</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>FIXME: getSDMXCodeListURI probably shouldn't have been called.</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="fn:getSliceKey">
        <xsl:param name="agencyIDPath"/>
        <xsl:param name="Group"/>

        <xsl:value-of select="$slice"/><xsl:value-of select="$agencyIDPath"/><xsl:text>/</xsl:text><xsl:value-of select="fn:getAttributeValue($Group/@id)"/>
    </xsl:function>


    <xsl:function name="fn:getConfig">
        <xsl:param name="label"/>

        <xsl:value-of select="document($pathToConfig)/rdf:RDF/rdf:Description/rdf:value/rdf:Description[rdfs:label = $label]/rdf:value"/>
    </xsl:function>
</xsl:stylesheet>
