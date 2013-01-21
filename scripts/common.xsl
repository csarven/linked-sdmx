<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URI: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:qb="http://purl.org/linked-data/cube#"
    xmlns:sdmx-concept="http://purl.org/linked-data/sdmx/2009/concept#"
    xmlns:fn="http://270a.info/xpath-function/"
    xmlns:structure="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/structure"
    xmlns:message="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message"
    xmlns:generic="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/generic"
    xmlns:common="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/common"

    xpath-default-namespace="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message"
    exclude-result-prefixes="xsl fn structure message generic common"
    >

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:variable name="pathToSDMXCode"><xsl:text>./sdmx-code.rdf</xsl:text></xsl:variable>
    <xsl:variable name="SDMXCode" select="document($pathToSDMXCode)/rdf:RDF"/>
    <xsl:variable name="pathToConfig"><xsl:text>./config.rdf</xsl:text></xsl:variable>
    <xsl:variable name="Config" select="document($pathToConfig)/rdf:RDF"/>
    <xsl:variable name="ConfigInterlinkAnnotationTypes" select="$Config/rdf:Description/rdf:value/rdf:Description[rdfs:label = 'interlinkAnnotationTypes']/rdf:value/rdf:Description"/>
    <xsl:variable name="xmlDocumentBaseUri" select="fn:getConfig('xmlDocumentBaseUri')"/>
    <xsl:variable name="xslDocument" select="fn:getConfig('xslDocument')"/>
    <xsl:variable name="now" select="fn:now()"/>
    <xsl:variable name="rdf" select="fn:getConfig('rdf')"/>
    <xsl:variable name="rdfs" select="fn:getConfig('rdfs')"/>
    <xsl:variable name="owl" select="fn:getConfig('owl')"/>
    <xsl:variable name="xsd" select="fn:getConfig('xsd')"/>
    <xsl:variable name="qb" select="fn:getConfig('qb')"/>
    <xsl:variable name="skos" select="fn:getConfig('skos')"/>
    <xsl:variable name="xkos" select="fn:getConfig('xkos')"/>
    <xsl:variable name="sdmx" select="fn:getConfig('sdmx')"/>
    <xsl:variable name="prov" select="fn:getConfig('prov')"/>
    <xsl:variable name="provenance" select="fn:getConfig('provenance')"/>
    <xsl:variable name="lang" select="fn:getConfig('lang')"/>
    <xsl:variable name="creator" select="fn:getConfig('creator')"/>
    <xsl:variable name="baseuri" select="fn:getConfig('baseuri')"/>
    <xsl:variable name="concept" select="fn:getConfig('concept')"/>
    <xsl:variable name="code" select="fn:getConfig('code')"/>
    <xsl:variable name="class" select="fn:getConfig('class')"/>
    <xsl:variable name="property" select="fn:getConfig('property')"/>
    <xsl:variable name="dataset" select="fn:getConfig('dataset')"/>
    <xsl:variable name="slice" select="fn:getConfig('slice')"/>
    <xsl:variable name="uriThingSeparator" select="fn:getConfig('uriThingSeparator')"/>
    <xsl:variable name="uriDimensionSeparator" select="fn:getConfig('uriDimensionSeparator')"/>
    <xsl:variable name="interlinkAnnotationTypes" select="fn:getConfig('interlinkAnnotationTypes')"/>

    <xsl:template name="langTextNode">
        <xsl:choose>
            <xsl:when test="@xml:lang">
                <xsl:copy-of select="@*[name() = 'xml:lang']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$lang">
                    <xsl:attribute name="xml:lang" select="$lang"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="normalize-space(text())"/>
    </xsl:template>

    <xsl:template match="structure:Name">
        <skos:prefLabel><xsl:call-template name="langTextNode"/></skos:prefLabel>
    </xsl:template>

    <xsl:template match="structure:Description">
        <skos:definition><xsl:call-template name="langTextNode"/></skos:definition>
    </xsl:template>

    <xsl:template match="@version">
        <owl:versionInfo><xsl:value-of select="."/></owl:versionInfo>
    </xsl:template>

    <xsl:template match="structure:Annotations/common:Annotation">
        <xsl:variable name="AnnotationType" select="normalize-space(common:AnnotationType)"/>
        <xsl:variable name="cIAT" select="$ConfigInterlinkAnnotationTypes[rdfs:label = $AnnotationType]"/>

        <xsl:if test="$AnnotationType and $cIAT">
            <xsl:variable name="rdfPredicate" select="$cIAT/rdf:predicate"/>
            <xsl:variable name="rdfType" select="$cIAT/rdf:type"/>

            <xsl:for-each select="common:AnnotationText">
                <xsl:element name="{$rdfPredicate}" namespace="{fn:getConfig(tokenize($rdfPredicate, ':')[1])}">
                    <xsl:choose>
                        <xsl:when test="$rdfType = 'XMLLiteral'">
                            <xsl:call-template name="langTextNode"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="$rdfType"/><xsl:value-of select="$uriThingSeparator"/><xsl:value-of select="normalize-space(.)"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:for-each>

            <xsl:for-each select="common:AnnotationTitle">
                <rdfs:comment><xsl:value-of select="."/></rdfs:comment>
            </xsl:for-each>

            <xsl:for-each select="common:AnnotationURL">
                <dcterms:identifier><xsl:value-of select="normalize-space(.)"/></dcterms:identifier>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@validFrom">
        <sdmx-concept:validFrom><xsl:value-of select="normalize-space(.)"/></sdmx-concept:validFrom>
    </xsl:template>

    <xsl:template match="@validTo">
        <sdmx-concept:validTo><xsl:value-of select="normalize-space(.)"/></sdmx-concept:validTo>
    </xsl:template>

    <xsl:template match="@uri">
        <rdfs:isDefinedBy rdf:resource="{normalize-space(.)}"/>
    </xsl:template>

    <xsl:template match="@urn">
        <dcterms:identifier rdf:resource="{normalize-space(.)}"/>
    </xsl:template>

    <xsl:template name="qbCodeListrdfsRange">
        <xsl:param name="SeriesKeyConceptsData" tunnel="yes"/>

        <xsl:variable name="codelist" select="@codelist"/>

        <xsl:if test="$codelist">
            <xsl:variable name="codelistVersion" select="@codelistVersion"/>
            <xsl:variable name="codelistAgency" select="$SeriesKeyConceptsData/@codelistAgency"/>

            <xsl:choose>
                <xsl:when test="lower-case(normalize-space($codelistAgency)) = 'sdmx'">
                    <xsl:variable name="codelistNormalized" select="fn:normalizeSDMXCodeListID($codelist)"/>

                    <xsl:variable name="SDMXConceptScheme" select="$SDMXCode/skos:ConceptScheme[skos:notation = $codelistNormalized][1]"/>

                    <qb:codeList rdf:resource="{$SDMXConceptScheme/@rdf:about}"/>
                    <rdfs:range rdf:resource="{$SDMXConceptScheme/rdfs:seeAlso[1]/@rdf:resource}"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="uriValidFromToSeparator">
                        <xsl:choose>
                            <xsl:when test="$codelistAgency and $codelistVersion">
                                <xsl:for-each select="//structure:CodeList[@id = $codelist and @agencyID = $codelistAgency and @version = $codelistVersion and (@validFrom and @validTo)]">
                                    <xsl:value-of select="fn:getUriValidFromToSeparator(@validFrom, @validTo)"/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <qb:codeList rdf:resource="{$code}{$codelistAgency}{$uriThingSeparator}{$codelist}{$uriValidFromToSeparator}"/>
                    <rdfs:range rdf:resource="{$class}{$codelistAgency}{$uriThingSeparator}{$codelist}{$uriValidFromToSeparator}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:function name="fn:normalizeSDMXCodeListID">
        <xsl:param name="codelist"/>

        <xsl:value-of select="replace(replace($codelist, '_SDMX', ''), 'CL_OBS_CONF', 'CL_CONF_STATUS')"/>
    </xsl:function>

    <xsl:function name="fn:getAttributeValue">
        <xsl:param name="attributeName"/>

        <xsl:if test="$attributeName">
            <xsl:value-of select="$attributeName"/>
        </xsl:if>
    </xsl:function>

    <xsl:template name="rdfDatatypeXSD">
        <xsl:param name="type"/>

        <xsl:attribute name="rdf:datatype"><xsl:text>http://www.w3.org/2001/XMLSchema#</xsl:text><xsl:value-of select="$type"/></xsl:attribute>
    </xsl:template>

    <xsl:function name="fn:getXSDType">
        <xsl:param name="type"/>

        <xsl:choose>
            <xsl:when test="$type = 'String'"><xsl:text>string</xsl:text></xsl:when>
            <xsl:when test="$type = 'BigInteger'"><xsl:text>integer</xsl:text></xsl:when>
            <xsl:when test="$type = 'Integer'"><xsl:text>int</xsl:text></xsl:when>
            <xsl:when test="$type = 'Long'"><xsl:text>long</xsl:text></xsl:when>
            <xsl:when test="$type = 'Short'"><xsl:text>short</xsl:text></xsl:when>
            <xsl:when test="$type = 'Decimal'"><xsl:text>decimal</xsl:text></xsl:when>
            <xsl:when test="$type = 'Float'"><xsl:text>float</xsl:text></xsl:when>
            <xsl:when test="$type = 'Double'"><xsl:text>double</xsl:text></xsl:when>
            <xsl:when test="$type = 'Boolean'"><xsl:text>boolean</xsl:text></xsl:when>
            <xsl:when test="$type = 'DateTime'"><xsl:text>dateTime</xsl:text></xsl:when>
            <xsl:when test="$type = 'Date'"><xsl:text>date</xsl:text></xsl:when>
            <xsl:when test="$type = 'Time'"><xsl:text>time</xsl:text></xsl:when>
            <xsl:when test="$type = 'Year'"><xsl:text>gYear</xsl:text></xsl:when>
            <xsl:when test="$type = 'Month'"><xsl:text>gMonth</xsl:text></xsl:when>
            <xsl:when test="$type = 'Day'"><xsl:text>gDay</xsl:text></xsl:when>
            <xsl:when test="$type = 'MonthDay'"><xsl:text>gMonthDay</xsl:text></xsl:when>
            <xsl:when test="$type = 'YearMonth'"><xsl:text>gYearMonth</xsl:text></xsl:when>
            <xsl:when test="$type = 'Duration'"><xsl:text>duration</xsl:text></xsl:when>
            <xsl:when test="$type = 'URI'"><xsl:text>anyURI</xsl:text></xsl:when>
<!--
TODO: Timespan, Count, InclusiveValueRange, ExclusiveValueRange, Incremental, ObservationalTimePeriod
-->
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="provActivity">
        <xsl:param name="provUsedA"/>
        <xsl:param name="provUsedB"/>
        <xsl:param name="provGenerated"/>

        <xsl:variable name="now" select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>

        <rdf:Description rdf:about="{$provenance}activity{$uriThingSeparator}{replace($now, '\D', '')}">
            <rdf:type rdf:resource="{$prov}Activity"/>
<!--dcterms:title-->
            <prov:startedAtTime rdf:datatype="{$xsd}dateTime"><xsl:value-of select="$now"/></prov:startedAtTime>
            <prov:used rdf:resource="{$provUsedA}"/>
            <xsl:if test="$provUsedB">
                <prov:used rdf:resource="{$provUsedB}"/>
            </xsl:if>
            <prov:used rdf:resource="{$xslDocument}"/>
            <prov:generated>
                <rdf:Description rdf:about="{$provGenerated}">
                    <prov:wasDerivedFrom rdf:resource="{$provUsedA}"/>
                </rdf:Description>
            </prov:generated>
        </rdf:Description>
    </xsl:template>

    <xsl:function name="fn:now">
        <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
    </xsl:function>

    <xsl:function name="fn:getUriValidFromToSeparator">
        <xsl:param name="validFrom"/>
        <xsl:param name="validTo"/>

        <xsl:text>-</xsl:text><xsl:value-of select="normalize-space($validFrom)"/><xsl:text>-</xsl:text><xsl:value-of select="normalize-space($validTo)"/>
    </xsl:function>


    <xsl:function name="fn:getSliceKey">
        <xsl:param name="agencyIDPath"/>
        <xsl:param name="Group"/>

        <xsl:value-of select="$slice"/><xsl:value-of select="$agencyIDPath"/><xsl:text>/</xsl:text><xsl:value-of select="fn:getAttributeValue($Group/@id)"/>
    </xsl:function>


    <xsl:function name="fn:getConfig">
        <xsl:param name="label"/>

        <xsl:value-of select="$Config/rdf:Description/rdf:value/rdf:Description[rdfs:label = $label]/rdf:value"/>
    </xsl:function>

    <xsl:function name="fn:getConceptAgencyID">
        <xsl:param name="doc"/>
        <xsl:param name="node"/>

        <xsl:variable name="ConceptAgencyID">
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
                <!-- Best bet if Concept is in the same document -->
                <xsl:otherwise>
                    <xsl:variable name="Concept" select="$doc/Concepts//structure:Concept[@id = $node/@conceptRef]"/>

                    <xsl:if test="count($Concept) = 1">
                        <xsl:choose>
                            <xsl:when test="$Concept/@agencyID">
                                <xsl:value-of select="$Concept/@agencyID"/>
                            </xsl:when>
                            <xsl:when test="$Concept/../structure:ConceptScheme[@agencyID]/@agencyID">
                                <xsl:value-of select="$Concept/../structure:ConceptScheme[@agencyID]/@agencyID"/>
                            </xsl:when>
                            <xsl:otherwise>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$ConceptAgencyID != ''">
                <xsl:value-of select="$ConceptAgencyID"/>
            </xsl:when>
            <!-- Fallback -->
            <xsl:otherwise>
                <xsl:value-of select="$doc/KeyFamilies/structure:KeyFamily[1]/@agencyID"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fn:getCodeListAgencyID">
        <xsl:param name="doc"/>
        <xsl:param name="node"/>

        <xsl:variable name="CodeListAgencyID">
            <xsl:choose>
                <xsl:when test="$node/@codelistAgency">
                    <xsl:value-of select="$node/@codelistAgency"/>
                </xsl:when>
                <!-- Best bet if Concept is in the same document -->
                <xsl:otherwise>
                    <xsl:variable name="CodeList" select="$doc/CodeLists//structure:CodeList[@id = $node/@codelist]"/>

                    <xsl:if test="count($CodeList) = 1">
                        <xsl:value-of select="$CodeList/@agencyID"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$CodeListAgencyID != ''">
                <xsl:value-of select="$CodeListAgencyID"/>
            </xsl:when>
            <!-- Fallback -->
            <xsl:otherwise>
                <xsl:value-of select="$doc/KeyFamilies/structure:KeyFamily[1]/@agencyID"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="fn:createSeriesKeyComponentData">
        <xsl:param name="concepts"/>
        <xsl:param name="KeyFamilyRef"/>

        <rdf:RDF>
            <xsl:for-each select="distinct-values($concepts)">
                <xsl:variable name="concept" select="."/>

                <xsl:element name="{$concept}">
                    <xsl:variable name="Component" select="$genericStructure/KeyFamilies/structure:KeyFamily[@id = $KeyFamilyRef]/structure:Components/*[@conceptRef = $concept]"/>

                    <xsl:variable name="codelist" select="$Component/@codelist"/>
                    <xsl:attribute name="codelist">
                        <xsl:value-of select="$codelist"/>
                    </xsl:attribute>

                    <xsl:attribute name="codelistAgency">
                        <xsl:if test="$codelist">
                            <xsl:value-of select="fn:getCodeListAgencyID($genericStructure, $Component)"/>
                        </xsl:if>
                    </xsl:attribute>

                    <xsl:variable name="conceptAgency">
                        <xsl:value-of select="fn:getConceptAgencyID($genericStructure, $Component)"/>
                    </xsl:variable>
                    <xsl:attribute name="conceptAgencyURI">
                        <xsl:value-of select="$conceptAgency"/><xsl:value-of select="$uriThingSeparator"/>
                    </xsl:attribute>

                    <xsl:attribute name="datatype">
                        <xsl:value-of select="fn:getXSDType($Component/structure:TextFormat/@textType)"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:function>

    <xsl:function name="fn:getConceptRole">
        <xsl:param name="node"/>

        <xsl:choose>
            <xsl:when test="$node/local-name() = 'PrimaryMeasureRole'">
                <xsl:text>PrimaryMeasureRole</xsl:text>
            </xsl:when>
            <xsl:when test="$node/local-name() = 'TimeDimension' or $node/@isTimeFormat">
                <xsl:text>TimeRole</xsl:text>
            </xsl:when>
            <xsl:when test="$node/@isFrequencyDimension = 'true' or $node/@isFrequencyAttribute = 'true'">
                <xsl:text>FrequencyRole</xsl:text>
            </xsl:when>
            <xsl:when test="$node/@isMeasureDimension = 'true'">
                <xsl:text>MeasureTypeRole</xsl:text>
            </xsl:when>
            <xsl:when test="$node/@isNonObservationalTimeDimension = 'true' or $node/@isNonObservationalTimeAttribute = 'true'">
                <xsl:text>NonObsTimeRole</xsl:text>
            </xsl:when>
            <xsl:when test="$node/@isEntityDimension = 'true' or $node/@isEntityAttribute = 'true'">
                <xsl:text>EntityRole</xsl:text>
            </xsl:when>
            <xsl:when test="$node/@isIdentityDimension = 'true' or $node/@isIdentityAttribute = 'true'">
                <xsl:text>IdentityRole</xsl:text>
            </xsl:when>
            <xsl:when test="$node/@isCountDimension = 'true' or $node/@isCountAttribute = 'true'">
                <xsl:text>CountRole</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>ConceptRole</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
