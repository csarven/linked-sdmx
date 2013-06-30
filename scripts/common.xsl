<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URI: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
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
    exclude-result-prefixes="xs xsl fn structure message generic common"
    >

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="pathToConfig"/>

    <xsl:variable name="pathToSDMXCode"><xsl:text>./sdmx-code.rdf</xsl:text></xsl:variable>
    <xsl:variable name="SDMXCode" select="document($pathToSDMXCode)/rdf:RDF"/>
    <xsl:variable name="pTC">
        <xsl:choose>
            <xsl:when test="$pathToConfig != ''">
                <xsl:value-of select="$pathToConfig"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>./config.rdf</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="Config" select="document($pTC)/rdf:RDF"/>
    <xsl:variable name="pathToAgencies"><xsl:text>./agencies.rdf</xsl:text></xsl:variable>
    <xsl:variable name="Agencies" select="document($pathToAgencies)/rdf:RDF"/>
    <xsl:variable name="agency" select="fn:getConfig('agency')"/>
    <xsl:variable name="agencyURI" select="$Agencies/rdf:Description[skos:notation = $agency]/@rdf:about"/>
    <xsl:variable name="ConfigInterlinkAnnotationTypes" select="$Config/rdf:Description/rdf:value/rdf:Description[rdfs:label = 'interlinkAnnotationTypes']/rdf:value/rdf:Description"/>
    <xsl:variable name="ConfigOmitComponents" select="$Config/rdf:Description/rdf:value/rdf:Description[rdfs:label = 'omitComponents']/rdf:value/rdf:Description"/>
    <xsl:variable name="xmlDocumentBaseUri" select="fn:getConfig('xmlDocumentBaseUri')"/>
    <xsl:variable name="xslDocument" select="fn:getConfig('xslDocument')"/>
    <xsl:variable name="provDocument" select="document($pathToProvDocument)/rdf:RDF"/>
    <xsl:variable name="license" select="fn:getConfig('license')"/>
    <xsl:variable name="now" select="fn:now()"/>
    <xsl:variable name="rdf" select="'http://www.w3.org/1999/02/22-rdf-syntax-ns#'"/>
    <xsl:variable name="rdfs" select="'http://www.w3.org/2000/01/rdf-schema#'"/>
    <xsl:variable name="owl" select="'http://www.w3.org/2002/07/owl#'"/>
    <xsl:variable name="xsd" select="'http://www.w3.org/2001/XMLSchema#'"/>
    <xsl:variable name="qb" select="'http://purl.org/linked-data/cube#'"/>
    <xsl:variable name="skos" select="'http://www.w3.org/2004/02/skos/core#'"/>
    <xsl:variable name="xkos" select="'http://purl.org/linked-data/xkos#'"/>
    <xsl:variable name="sdmx" select="'http://purl.org/linked-data/sdmx#'"/>
    <xsl:variable name="prov" select="'http://www.w3.org/ns/prov#'"/>
    <xsl:variable name="creator" select="fn:getConfig('creator')"/>
    <xsl:variable name="lang" select="fn:getConfig('lang')"/>
    <xsl:variable name="uriThingSeparator" select="fn:getConfig('uriThingSeparator')"/>
    <xsl:variable name="uriDimensionSeparator" select="fn:getConfig('uriDimensionSeparator')"/>
    <xsl:variable name="provenance" select="concat($agencyURI, 'provenance', $uriThingSeparator)"/>
    <xsl:variable name="concept" select="concat($agencyURI, 'concept/')"/>
    <xsl:variable name="code" select="concat($agencyURI, 'code/')"/>
    <xsl:variable name="class" select="concat($agencyURI, 'class/')"/>
    <xsl:variable name="property" select="concat($agencyURI, 'property', $uriThingSeparator)"/>
    <xsl:variable name="dataset" select="concat($agencyURI, 'dataset/')"/>
    <xsl:variable name="structure" select="concat($agencyURI, 'structure/')"/>
    <xsl:variable name="slice" select="concat($agencyURI, 'slice', $uriThingSeparator)"/>

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
        <xsl:value-of select="normalize-space(.)"/>
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
        <xsl:variable name="cIAT" select="$ConfigInterlinkAnnotationTypes[rdf:type = $AnnotationType]"/>

        <xsl:if test="$AnnotationType and $cIAT">
            <xsl:variable name="rdfPredicate" select="$cIAT/rdf:predicate"/>
            <xsl:variable name="rdfRange" select="$cIAT/rdfs:range"/>

            <xsl:for-each select="*[local-name() = $cIAT/rdfs:label]">
                <xsl:element name="{$rdfPredicate}" namespace="{fn:getConfig(tokenize($rdfPredicate, ':')[1])}">
                    <xsl:choose>
                        <xsl:when test="$rdfRange = 'Literal'">
                            <xsl:call-template name="langTextNode"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="$rdfRange"/><xsl:value-of select="$uriThingSeparator"/><xsl:value-of select="normalize-space(.)"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
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
        <dcterms:identifier><xsl:value-of select="normalize-space(.)"/></dcterms:identifier>
    </xsl:template>

    <xsl:template name="ConceptLabels">
        <xsl:param name="Concept"/>

        <xsl:for-each select="$Concept">
            <xsl:apply-templates select="structure:Name"/>
        </xsl:for-each>
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
                    <qb:codeList rdf:resource="{fn:getComponentURI('code', $codelistAgency)}/{fn:getVersion($codelistVersion)}/{$codelist}"/>
                    <rdfs:range rdf:resource="{fn:getComponentURI('class', $codelistAgency)}/{fn:getVersion($codelistVersion)}/{$codelist}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:function name="fn:getAgencyURI">
        <xsl:param name="agency"/>

        <xsl:for-each select="$Agencies/rdf:Description/skos:notation">
            <xsl:if test="starts-with(lower-case($agency), lower-case(.))">
                <xsl:value-of select="../@rdf:about"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="fn:getComponentURI">
        <xsl:param name="component"/>
        <xsl:param name="agency"/>

        <xsl:variable name="uri" select="fn:getAgencyURI($agency)"/>
        <xsl:choose>
            <xsl:when test="$uri != ''">
                <xsl:value-of select="concat($uri, $component)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($agencyURI, $component)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fn:normalizeSDMXCodeListID">
        <xsl:param name="codelist"/>

        <xsl:value-of select="replace(replace($codelist, '_SDMX', ''), 'CL_OBS_CONF', 'CL_CONF_STATUS')"/>
    </xsl:function>

    <xsl:function name="fn:detectDatatype">
        <xsl:param name="value"/>

        <xsl:choose>
            <xsl:when test="string($value) castable as xs:decimal">
                <xsl:value-of select="'decimal'"/>
            </xsl:when>
            <xsl:when test="string($value) castable as xs:double">
                <xsl:value-of select="'double'"/>
            </xsl:when>
            <xsl:when test="string($value) castable as xs:float">
                <xsl:value-of select="'float'"/>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="rdfDatatypeXSD">
        <xsl:param name="type"/>

        <xsl:if test="$type != ''">
            <xsl:attribute name="rdf:datatype"><xsl:text>http://www.w3.org/2001/XMLSchema#</xsl:text><xsl:value-of select="$type"/></xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:function name="fn:getXSDType">
        <xsl:param name="type"/>

        <xsl:choose>
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


    <xsl:function name="fn:getResourceRefPeriod">
        <xsl:param name="date"/>

        <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)(-[0-1][0-9]-[0-3][0-9])">
            <xsl:matching-substring>
                <xsl:value-of select="concat('http://reference.data.gov.uk/id/day/', $date)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)(-[0-1][0-9])">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat('http://reference.data.gov.uk/id/month/', $date)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)(-?Q([1-4]))" flags="i">
                            <xsl:matching-substring>
                                <xsl:value-of select="concat('http://reference.data.gov.uk/id/quarter/', regex-group(1), '-Q', regex-group(5))"/>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)">
                                    <xsl:matching-substring>
                                       <xsl:value-of select="concat('http://reference.data.gov.uk/id/year/', regex-group(1))"/>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:template name="provenance">
        <xsl:param name="provUsedA"/>
        <xsl:param name="provUsedB"/>
        <xsl:param name="provGenerated"/>
        <xsl:param name="entityID"/>

        <xsl:variable name="now" select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
        <xsl:variable name="provActivity" select="concat($provenance, 'activity', $uriThingSeparator, replace($now, '\D', ''))"/>

        <rdf:Description rdf:about="{$provActivity}">
            <rdf:type rdf:resource="{$prov}Activity"/>
            <rdfs:label xml:lang="en"><xsl:value-of select="concat('Transformed ', $entityID, ' data')"/></rdfs:label>

            <xsl:variable name="informedBy" select="$provDocument/rdf:Description[prov:generated/@rdf:resource = $provUsedA]/@rdf:about"/>
            <xsl:if test="$informedBy">
                <prov:wasInformedBy rdf:resource="{$informedBy}"/>
            </xsl:if>
            <prov:startedAtTime rdf:datatype="{$xsd}dateTime"><xsl:value-of select="$now"/></prov:startedAtTime>
            <prov:wasAssociatedWith rdf:resource="{$creator}"/>
            <prov:used rdf:resource="{$provUsedA}"/>
            <xsl:if test="$provUsedB">
                <prov:used rdf:resource="{$provUsedB}"/>
                <xsl:variable name="informedBy" select="$provDocument/rdf:Description[prov:generated/rdf:resource = $provUsedB]/@rdf:about"/>

                <xsl:if test="$informedBy">
                    <prov:wasInformedBy rdf:resource="{$informedBy}"/>
                </xsl:if>
            </xsl:if>
            <prov:used rdf:resource="{$xslDocument}"/>
            <prov:generated>
                <rdf:Description rdf:about="{$provGenerated}">
                    <rdf:type rdf:resource="{$prov}Entity"/>
                    <prov:wasAttributedTo rdf:resource="{$creator}"/>
                    <prov:generatedAtTime rdf:datatype="{$xsd}dateTime"><xsl:value-of select="$now"/></prov:generatedAtTime>
                    <prov:wasDerivedFrom rdf:resource="{$provUsedA}"/>
                    <prov:wasGeneratedBy rdf:resource="{$provActivity}"/>
                    <xsl:if test="$license">
                        <dcterms:license rdf:resource="{$license}"/>
                    </xsl:if>
                    <dcterms:issued rdf:datatype="{$xsd}dateTime"><xsl:value-of select="$now"/></dcterms:issued>
                    <dcterms:creator rdf:resource="{$creator}"/>
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


    <xsl:template name="DataSetName">
        <xsl:param name="datasetID"/>

        <xsl:if test="$datasetID != '' and $dataflowStructure != ''">
            <dcterms:title><xsl:value-of select="$dataflowStructure/Dataflows/structure:Dataflow[@id = $datasetID]/structure:Name/text()"/></dcterms:title>
        </xsl:if>
    </xsl:template>


    <xsl:function name="fn:getVersion">
        <xsl:param name="version"/>

        <xsl:choose>
            <xsl:when test="$version">
                <xsl:value-of select="replace(normalize-space($version), '\s+', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'1.0'"/>
            </xsl:otherwise>
        </xsl:choose>
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
                    <xsl:variable name="Component" select="$genericStructure/KeyFamilies/structure:KeyFamily[@id = $KeyFamilyRef]/structure:Components/*[@conceptRef = $concept][1]"/>

                    <xsl:attribute name="component">
                        <xsl:value-of select="$Component/local-name()"/>
                    </xsl:attribute>

                    <xsl:attribute name="conceptRole">
                        <xsl:value-of select="fn:getConceptRole($Component)"/>
                    </xsl:attribute>

                    <xsl:variable name="codelist" select="$Component/@codelist"/>
                    <xsl:attribute name="codelist">
                        <xsl:value-of select="$codelist"/>
                    </xsl:attribute>

                    <xsl:variable name="codelistAgency" select="fn:getCodeListAgencyID($genericStructure, $Component)"/>

                    <xsl:attribute name="codelistAgency">
                        <xsl:value-of select="$codelistAgency"/>
                    </xsl:attribute>

                    <xsl:attribute name="codelistVersion">
                        <xsl:choose>
                            <xsl:when test="$Component/@codelistVersion">
                                <xsl:value-of select="$Component/@codelistVersion"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="fn:getVersion($genericStructure/CodeLists//structure:CodeList[@id = $codelist and @agencyID = $codelistAgency]/@version)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>

                    <xsl:variable name="conceptAgency">
                        <xsl:value-of select="fn:getConceptAgencyID($genericStructure, $Component)"/>
                    </xsl:variable>
                    <xsl:attribute name="conceptAgencyURI">
                        <xsl:value-of select="$conceptAgency"/><xsl:value-of select="$uriThingSeparator"/>
                    </xsl:attribute>

                    <xsl:variable name="conceptSchemeRef" select="$Component/@conceptSchemeRef"/>
                    <xsl:attribute name="conceptScheme">
                        <xsl:choose>
                            <xsl:when test="$conceptSchemeRef">
                                <xsl:value-of select="$conceptSchemeRef"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$genericStructure/Concepts//structure:Concept[@id = $concept]/../@id"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>

                    <xsl:attribute name="conceptVersion">
                        <xsl:choose>
                            <xsl:when test="$Component/@conceptVersion">
                                <xsl:value-of select="$Component/@conceptVersion"/>
                            </xsl:when>
                            <xsl:otherwise>
<!--
TODO: This should probably get the version from ConceptScheme just as the structureConcept template
-->
                                <xsl:value-of select="fn:getVersion($genericStructure/Concepts//structure:Concept[@id = $concept]/@version)"/>
                            </xsl:otherwise>
                        </xsl:choose>
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
            <xsl:when test="$node/local-name() = 'PrimaryMeasure'">
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
