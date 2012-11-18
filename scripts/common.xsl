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
</xsl:stylesheet>
