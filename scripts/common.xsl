<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URI: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:sdmx-concept="http://purl.org/linked-data/sdmx/2009/concept#"
    xmlns:fn="http://270a.info/xpath-function/"
    xmlns:structure="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/structure"
    xmlns:message="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message"
    xmlns:generic="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/generic"
    xmlns:common="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/common"
    >

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:variable name="pathToConfig"><xsl:text>./config.rdf</xsl:text></xsl:variable>
    <xsl:variable name="rdf" select="fn:getConfig('rdf')"/>
    <xsl:variable name="xsd" select="fn:getConfig('xsd')"/>
    <xsl:variable name="qb" select="fn:getConfig('qb')"/>
    <xsl:variable name="skos" select="fn:getConfig('skos')"/>
    <xsl:variable name="xkos" select="fn:getConfig('xkos')"/>
    <xsl:variable name="sdmx" select="fn:getConfig('sdmx')"/>
    <xsl:variable name="lang" select="fn:getConfig('lang')"/>
    <xsl:variable name="baseuri" select="fn:getConfig('baseuri')"/>
    <xsl:variable name="concept" select="fn:getConfig('concept')"/>
    <xsl:variable name="code" select="fn:getConfig('code')"/>
    <xsl:variable name="property" select="fn:getConfig('property')"/>
    <xsl:variable name="dataset" select="fn:getConfig('dataset')"/>
    <xsl:variable name="slice" select="fn:getConfig('slice')"/>
    <xsl:variable name="uriThingSeparator" select="fn:getConfig('uriThingSeparator')"/>
    <xsl:variable name="uriDimensionSeparator" select="fn:getConfig('uriDimensionSeparator')"/>
    <xsl:variable name="interlinkAnnotationTypes" select="fn:getConfig('interlinkAnnotationTypes')"/>

    <xsl:template name="langTextNode">
        <xsl:if test="@xml:lang">
            <xsl:copy-of select="@*[name() = 'xml:lang']"/>
        </xsl:if>
        <xsl:value-of select="text()"/>
    </xsl:template>

    <xsl:template match="structure:Name">
        <skos:prefLabel><xsl:call-template name="langTextNode"/></skos:prefLabel>
    </xsl:template>

    <xsl:template match="structure:Description">
        <skos:definition><xsl:call-template name="langTextNode"/></skos:definition>
    </xsl:template>

    <xsl:template match="structure:Annotations/common:Annotation">
        <xsl:variable name="AnnotationType" select="normalize-space(common:AnnotationType)"/>

        <xsl:if test="$AnnotationType">
            <xsl:variable name="ConfigInterlinkAnnotationTypes" select="document($pathToConfig)/rdf:RDF/rdf:Description/rdf:value/rdf:Description[rdfs:label = 'interlinkAnnotationTypes']/rdf:value/rdf:Description[rdfs:label = $AnnotationType]"/>
<!--
FIXME: namespace is not necessarily ?kos
-->
            <xsl:for-each select="common:AnnotationText">
                <xsl:variable name="AnnotationText" select="normalize-space(.)"/>

                <xsl:choose>
                    <xsl:when test="string-length($ConfigInterlinkAnnotationTypes) > 0">
                        <xsl:for-each select="$ConfigInterlinkAnnotationTypes">
                            <xsl:element name="{rdf:predicate}" namespace="{$xkos}">
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="rdf:type"/><xsl:value-of select="$uriThingSeparator"/><xsl:value-of select="$AnnotationText"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="property:{$AnnotationType}" namespace="{$property}">
                            <xsl:call-template name="langTextNode"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>

        <xsl:for-each select="common:AnnotationTitle">
            <rdfs:comment><xsl:value-of select="."/></rdfs:comment>
        </xsl:for-each>

        <xsl:for-each select="common:AnnotationURL">
            <rdfs:seeAlso rdf:resource="{normalize-space(.)}"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="@validFrom">
        <sdmx-concept:validFrom><xsl:value-of select="."/></sdmx-concept:validFrom>
    </xsl:template>

    <xsl:template match="@validTo">
        <sdmx-concept:validTo><xsl:value-of select="."/></sdmx-concept:validTo>
    </xsl:template>

    <xsl:template match="@uri">
        <rdfs:isDefinedBy rdf:resource="normalize-space(.)"/>
    </xsl:template>

    <xsl:template match="@urn">
        <dcterms:identifier rdf:resource="normalize-space(.)"/>
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


    <xsl:function name="fn:getUriValidFromToSeparator">
        <xsl:param name="validFrom"/>
        <xsl:param name="validTo"/>

        <xsl:text>-</xsl:text><xsl:value-of select="normalize-space($validFrom)"/><xsl:text>-</xsl:text><xsl:value-of select="normalize-space($validTo)"/>
    </xsl:function>

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

    <xsl:function name="fn:getConceptAgencyID">
        <xsl:param name="doc"/>
        <xsl:param name="node"/>

        <xsl:variable name="ConceptAgencyID">
            <xsl:variable name="Concept" select="$doc/descendant::structure:Concept[@id = $node/@conceptRef]"/>

            <xsl:if test="count($Concept) = 1">
                <xsl:choose>
                    <xsl:when test="$Concept/@agencyID">
                        <xsl:value-of select="$Concept/@agencyID"/>
                    </xsl:when>
                    <xsl:when test="$Concept/ancestor::structure:ConceptScheme[@agencyID]/@agencyID">
                        <xsl:value-of select="$Concept/ancestor::structure:ConceptScheme[@agencyID]/@agencyID"/>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="cAgency">
            <xsl:choose>
                <xsl:when test="$node/@conceptAgency">
                    <xsl:value-of select="$node/@conceptAgency"/>
                </xsl:when>
                <xsl:when test="$node/@conceptSchemeAgency">
                    <xsl:value-of select="$node/@conceptSchemeAgency"/>
                </xsl:when>
                <xsl:when test="$node/@codelistAgency">
                    <xsl:value-of select="$node/@codelistAgency"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="KeyFamilyAgencyID" select="$doc/descendant::structure:KeyFamily/@agencyID"/>

        <xsl:choose>
            <!-- Best bet if Concept is in the same document -->
            <xsl:when test="$ConceptAgencyID">
                <xsl:value-of select="$ConceptAgencyID"/>
            </xsl:when>
            <!-- Cheapest -->
            <xsl:when test="$cAgency">
                <xsl:value-of select="$cAgency"/>
            </xsl:when>
            <!-- Fallback -->
            <xsl:otherwise>
                <xsl:value-of select="$KeyFamilyAgencyID"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
