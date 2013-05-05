<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URI: http://csarven.ca/#i

    Description: XSLT for SDMX to RDF
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:fn="http://270a.info/xpath-function/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:xkos="http://purl.org/linked-data/xkos#"
    xmlns:qb="http://purl.org/linked-data/cube#"
    xmlns:sdmx="http://purl.org/linked-data/sdmx#"
    xmlns:sdmx-attribute="http://purl.org/linked-data/sdmx/2009/attribute#"
    xmlns:sdmx-code="http://purl.org/linked-data/sdmx/2009/code#"
    xmlns:sdmx-concept="http://purl.org/linked-data/sdmx/2009/concept#"
    xmlns:sdmx-dimension="http://purl.org/linked-data/sdmx/2009/dimension#"
    xmlns:sdmx-measure="http://purl.org/linked-data/sdmx/2009/measure#"
    xmlns:sdmx-metadata="http://purl.org/linked-data/sdmx/2009/metadata#"
    xmlns:sdmx-subject="http://purl.org/linked-data/sdmx/2009/subject#"
    xmlns:structure="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/structure"
    xmlns:message="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message"
    xmlns:generic="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/generic"
    xmlns:common="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/common"

    xpath-default-namespace="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message"
    exclude-result-prefixes="xsl fn structure message generic common"
    >

    <xsl:import href="common.xsl"/>

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="xmlDocument"/>
    <xsl:param name="pathToGenericStructure"/>
    <xsl:param name="pathToProvDocument"/>
    <xsl:param name="dataSetID"/>
    <xsl:param name="pathToDataflow"/>
    <xsl:variable name="genericStructure" select="document($pathToGenericStructure)/Structure"/>
    <xsl:variable name="dataflowStructure" select="document($pathToDataflow)/Structure"/>


    <xsl:template match="/">
        <rdf:RDF>
            <xsl:namespace name="property" select="$property"/>

            <rdf:Description rdf:about="{$creator}">
                <rdf:type rdf:resource="{$prov}Agent"/>
            </rdf:Description>

            <xsl:call-template name="KeyFamily"/>

            <xsl:call-template name="Concepts"/>

            <xsl:call-template name="CodeLists"/>

            <xsl:call-template name="HierarchicalCodelists"/>

            <xsl:call-template name="DataSets"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="KeyFamily">
        <xsl:for-each select="Structure/KeyFamilies/structure:KeyFamily">
            <xsl:variable name="id" select="@id"/>

            <xsl:variable name="structureURI">
                <xsl:value-of select="$structure"/>
                <xsl:value-of select="$id"/>
            </xsl:variable>

<!--
FIXME: $pathToGenericStructure should be replaced with an HTTP URI ??? Is this irrelevant now?
-->
            <xsl:call-template name="provenance">
                <xsl:with-param name="provUsedA" select="resolve-uri(tokenize($xmlDocument, '/')[last()], $xmlDocumentBaseUri)"/>
                <xsl:with-param name="provGenerated" select="$structureURI"/>
                <xsl:with-param name="entityID" select="$id"/>
            </xsl:call-template>

            <rdf:Description rdf:about="{$structureURI}">
                <rdf:type rdf:resource="{$sdmx}DataStructureDefinition"/>
                <rdf:type rdf:resource="{$qb}DataStructureDefinition"/>

<!-- TODO:
* Review these properties. Some are close enough to existing SDMX, some I made them up - they should be added to sdmx* vocabs perhpas, so, consider creating sdmx-concept URIs for isFinal/isExternalReference/validFrom/validTo ...?
-->
                <sdmx-concept:dsi><xsl:value-of select="$id"/></sdmx-concept:dsi>

                <xsl:if test="@agencyID">
                    <sdmx-concept:mAgency><xsl:value-of select="@agencyID"/></sdmx-concept:mAgency>
                </xsl:if>

                <xsl:apply-templates select="@version"/>

                <xsl:apply-templates select="@uri"/>
                <xsl:apply-templates select="@urn"/>

                <xsl:if test="@isFinal">
                    <sdmx-concept:isFinal rdf:datatype="{$xsd}boolean"><xsl:value-of select="@isFinal"/></sdmx-concept:isFinal>
                </xsl:if>

                <xsl:apply-templates select="@validFrom"/>
                <xsl:apply-templates select="@validTo"/>

                <xsl:apply-templates select="structure:Name"/>

                <xsl:apply-templates select="structure:Description"/>

                <xsl:call-template name="structureComponents">
                    <xsl:with-param name="KeyFamilyID" select="$id" tunnel="yes"/>
                </xsl:call-template>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="structureComponents">
        <xsl:param name="KeyFamilyID" tunnel="yes"/>

        <xsl:variable name="concepts" select="distinct-values(structure:Components/*/@conceptRef)"/>

        <xsl:variable name="SeriesKeyConceptsData" select="fn:createSeriesKeyComponentData($concepts, $KeyFamilyID)"/>

        <xsl:for-each select="structure:Components/*[local-name() != 'Group']">
<!--
FIXME: This could reuse the agencyID that's determined from SeriesKeyConceptsData above instead. Cheaper.
-->
            <xsl:variable name="agencyID" select="fn:getConceptAgencyID(/Structure,.)"/>
            <qb:component>
                <qb:ComponentSpecification>
                    <xsl:variable name="conceptRef" select="@conceptRef"/>
                    <xsl:variable name="conceptScheme">
                        <xsl:variable name="cS" select="$SeriesKeyConceptsData/*[name() = $conceptRef]/@conceptScheme"/>
                        <xsl:if test="$cS != ''">
                            <xsl:value-of select="concat('/', $cS)"/>
                        </xsl:if>
                    </xsl:variable>

                    <xsl:variable name="conceptURI" select="concat($concept, $SeriesKeyConceptsData/*[name() = $conceptRef]/@conceptVersion, $conceptScheme, $uriThingSeparator, @conceptRef)"/>

                    <xsl:variable name="Concept" select="//Concepts//structure:Concept[@id = $conceptRef]"/>
                    <xsl:choose>
<!--
XXX:
Should we give any special treatment to TimeDimension even though qb currently doesn't?
-->
                        <xsl:when test="local-name() = 'Dimension' or local-name() = 'TimeDimension'">
                            <qb:dimension>
                                <rdf:Description rdf:about="{$property}{$conceptRef}">
                                    <rdf:type rdf:resource="{$qb}DimensionProperty"/>
                                    <rdf:type rdf:resource="{$qb}CodedProperty"/>
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept>
                                        <rdf:Description rdf:about="{$conceptURI}">
                                            <rdf:type rdf:resource="{$sdmx}{fn:getConceptRole(.)}"></rdf:type>
                                        </rdf:Description>
                                    </qb:concept>
                                    <xsl:call-template name="qbCodeListrdfsRange">
                                        <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData/*[name() = $conceptRef]" tunnel="yes"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="ConceptLabels">
                                        <xsl:with-param name="Concept" select="$Concept"/>
                                    </xsl:call-template>
                                </rdf:Description>
                            </qb:dimension>

<!--
XXX: Order matters but consider the case when XML doesn't list all dimensions one after another. It won't be sequential (skips numbers)
-->
                            <qb:order rdf:datatype="{$xsd}integer"><xsl:value-of select="position()"/></qb:order>

<!--
TODO:
RDF Data Cube lets you have an attachment at this level. See what indicates this in SDMX-ML
-->
                        </xsl:when>

<!--
TODO:
Consider what to do with optional <TextFormat textType="Double"/> or whatever. Probably a datatype on the range of the measure instead.
-->
                        <xsl:when test="local-name() = 'PrimaryMeasure'">
                            <qb:measure>
                                <rdf:Description rdf:about="{$property}{@conceptRef}">
                                    <rdf:type rdf:resource="{$qb}MeasureProperty"/>
                                    <rdf:type rdf:resource="{$qb}CodedProperty"/>
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept>
                                        <rdf:Description rdf:about="{$conceptURI}">
                                            <rdf:type rdf:resource="{$sdmx}{fn:getConceptRole(.)}"></rdf:type>
                                        </rdf:Description>
                                    </qb:concept>
                                    <xsl:call-template name="qbCodeListrdfsRange">
                                        <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData/*[name() = $conceptRef]" tunnel="yes"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="ConceptLabels">
                                        <xsl:with-param name="Concept" select="$Concept"/>
                                    </xsl:call-template>
                                </rdf:Description>
                            </qb:measure>
                        </xsl:when>

<!--
TODO:
Multiple measures
-->
                        <xsl:when test="local-name() = 'CrossSectionalMeasure'">
                        </xsl:when>


                        <xsl:when test="local-name() = 'Attribute'">
                            <qb:attribute>
                                <rdf:Description rdf:about="{$property}{@conceptRef}">
                                    <rdf:type rdf:resource="{$qb}AttributeProperty"/>
                                    <rdf:type rdf:resource="{$qb}CodedProperty"/>
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept>
                                        <rdf:Description rdf:about="{$conceptURI}">
                                            <rdf:type rdf:resource="{$sdmx}{fn:getConceptRole(.)}"></rdf:type>
                                        </rdf:Description>
                                    </qb:concept>
                                    <xsl:call-template name="qbCodeListrdfsRange">
                                        <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData/*[name() = $conceptRef]" tunnel="yes"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="ConceptLabels">
                                        <xsl:with-param name="Concept" select="$Concept"/>
                                    </xsl:call-template>
                                </rdf:Description>
                            </qb:attribute>

                            <xsl:choose>
                                <xsl:when test="@attachmentLevel = 'DataSet'">
                                    <qb:componentAttachment rdf:resource="{$qb}DataSet"/>
                                </xsl:when>
                                <xsl:when test="@attachmentLevel = 'Group'">
                                    <qb:componentAttachment rdf:resource="{$qb}Slice"/>
<!--
TODO:
structure:AttachmentGroup is "to indicate which declared group or groups the attribute may be attached to".
"TextFormat element to specify constraints on the value of the uncoded attribute"
-->
                                </xsl:when>
                                <xsl:when test="@attachmentLevel = 'Series'">
<!--
FIXME: Is this somehow for qb:Dimension?
-->
                                    <qb:componentAttachment rdf:resource="{$qb}Observation"/>
                                </xsl:when>

                                <xsl:otherwise>
                                    <qb:componentAttachment rdf:resource="{$qb}Observation"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>

                        <xsl:otherwise>
                        </xsl:otherwise>
                    </xsl:choose>
                </qb:ComponentSpecification>
            </qb:component>
        </xsl:for-each>


        <xsl:for-each select="structure:Components/structure:Group">
            <xsl:variable name="id" select="@id"/>

            <qb:sliceKey>
                <rdf:Description rdf:about="{$slice}{$KeyFamilyID}{$uriThingSeparator}{$id}">
                    <rdf:type rdf:resource="{$qb}SliceKey"/>
                    <skos:notation><xsl:value-of select="$id"/></skos:notation>

                    <xsl:for-each select="structure:DimensionRef">
                        <qb:componentProperty rdf:resource="{$property}{normalize-space(.)}"/>
                    </xsl:for-each>
                </rdf:Description>
            </qb:sliceKey>
        </xsl:for-each>
    </xsl:template>


<!--
TODO:
Check where to get ConceptScheme
-->
    <xsl:template name="Concepts">
        <xsl:for-each select="Structure/Concepts/structure:ConceptScheme">
            <xsl:call-template name="structureConceptScheme"/>
        </xsl:for-each>

        <xsl:for-each select="Structure/Concepts/structure:Concept">
            <xsl:call-template name="structureConcept"/>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="structureConceptScheme">
        <xsl:variable name="version" select="fn:getVersion(@version)"/>
        <xsl:variable name="conceptSchemeURI" select="concat($concept, $version, '/', @id)"/>

        <xsl:call-template name="provenance">
            <xsl:with-param name="provUsedA" select="resolve-uri(tokenize($xmlDocument, '/')[last()], $xmlDocumentBaseUri)"/>
            <xsl:with-param name="provGenerated" select="$conceptSchemeURI"/>
            <xsl:with-param name="entityID" select="@id"/>
        </xsl:call-template>


        <rdf:Description rdf:about="{$conceptSchemeURI}">
<!--
XXX:
SDMX-ML actually differentiates ConceptScheme from CodeList. Add sdmx:ConceptScheme?
-->
            <rdf:type rdf:resource="{$skos}ConceptScheme"/>

            <xsl:apply-templates select="@uri"/>
            <xsl:apply-templates select="@urn"/>
            <xsl:apply-templates select="@version"/>

            <skos:notation><xsl:value-of select="@id"/></skos:notation>

            <xsl:apply-templates select="structure:Name"/>

            <xsl:for-each select="structure:Concept">
                <skos:hasTopConcept>
                    <xsl:call-template name="structureConcept">
                        <xsl:with-param name="conceptSchemeURI" select="$conceptSchemeURI"/>
                    </xsl:call-template>
                </skos:hasTopConcept>
            </xsl:for-each>
        </rdf:Description>
    </xsl:template>


    <xsl:template name="structureConcept">
        <xsl:param name="conceptSchemeURI"/>

<!--
XXX: Is it possible to have a Concept version that's different than the version than the ConceptScheme that it is in?
-->
        <xsl:variable name="version" select="fn:getVersion(@version)"/>
        <xsl:variable name="conceptURI">
            <xsl:choose>
                <xsl:when test="$conceptSchemeURI">
                    <xsl:value-of select="concat($conceptSchemeURI, $uriThingSeparator, @id)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($concept, $version, '/', @id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <rdf:Description rdf:about="{$conceptURI}">
            <rdf:type rdf:resource="{$sdmx}Concept"/>
            <rdf:type rdf:resource="{$skos}Concept"/>

            <xsl:if test="$conceptSchemeURI">
                <skos:topConceptOf rdf:resource="{$conceptSchemeURI}"/>
                <skos:inScheme rdf:resource="{$conceptSchemeURI}"/>
            </xsl:if>

            <xsl:apply-templates select="@uri"/>
            <xsl:apply-templates select="@urn"/>
            <xsl:apply-templates select="@version"/>

            <skos:notation><xsl:value-of select="@id"/></skos:notation>

            <xsl:apply-templates select="structure:Name"/>

            <xsl:apply-templates select="structure:Description"/>

<!--
TODO:
structure:textFormat
-->

            <xsl:apply-templates select="structure:Annotations/common:Annotation"/>
        </rdf:Description>
    </xsl:template>



    <xsl:template name="CodeLists">
        <xsl:for-each select="Structure/CodeLists/structure:CodeList">
            <xsl:if test="starts-with(@agencyID, $agency) or
                          fn:getAgencyURI(@agencyID) = fn:getAgencyURI($agency)">

                <xsl:variable name="id" select="@id"/>

                <xsl:variable name="version" select="fn:getVersion(@version)"/>
                <xsl:variable name="codeListURI" select="concat($code, $version, '/', $id)"/>

                <xsl:call-template name="provenance">
                    <xsl:with-param name="provUsedA" select="resolve-uri(tokenize($xmlDocument, '/')[last()], $xmlDocumentBaseUri)"/>
                    <xsl:with-param name="provGenerated" select="$codeListURI"/>
                    <xsl:with-param name="entityID" select="$id"/>
                </xsl:call-template>

                <rdf:Description rdf:about="{$codeListURI}">
                    <rdf:type rdf:resource="{$sdmx}CodeList"/>
                    <rdf:type rdf:resource="{$skos}ConceptScheme"/>

                    <xsl:variable name="classURI" select="concat($class, $version, '/', $id)"/>

                    <rdfs:seeAlso>
                        <rdf:Description rdf:about="{$classURI}">
                            <rdf:type rdf:resource="{$rdfs}Class"/>
                            <rdf:type rdf:resource="{$owl}Class"/>
                            <rdfs:subClassOf rdf:resource="{$skos}Concept"/>
                            <rdfs:seeAlso rdf:resource="{$codeListURI}"/>
                            <xsl:apply-templates select="structure:Name"/>
                        </rdf:Description>
                    </rdfs:seeAlso>

                    <xsl:apply-templates select="@uri"/>
                    <xsl:apply-templates select="@validFrom"/>
                    <xsl:apply-templates select="@validTo"/>
                    <xsl:apply-templates select="@version"/>

                    <skos:notation><xsl:value-of select="$id"/></skos:notation>
                    <xsl:apply-templates select="structure:Name"/>

                    <xsl:for-each select="structure:Code">
                        <xsl:variable name="codeURI" select="concat($codeListURI, $uriThingSeparator, @value)"/>

                        <skos:hasTopConcept>
                            <rdf:Description rdf:about="{$codeURI}">
                                <rdf:type rdf:resource="{$sdmx}Concept"/>
                                <rdf:type rdf:resource="{$skos}Concept"/>
                                <rdf:type rdf:resource="{$classURI}"/>
                                <skos:topConceptOf rdf:resource="{$codeListURI}"/>
                                <skos:inScheme rdf:resource="{$codeListURI}"/>

                                <xsl:apply-templates select="@urn"/>

                                <xsl:if test="@parentCode">
                                    <xkos:isPartOf>
                                        <rdf:Description rdf:about="{$code}{$version}/{$id}{$uriThingSeparator}{@parentCode}">
                                            <xkos:hasPart rdf:resource="{$codeURI}"/>
                                        </rdf:Description>
                                    </xkos:isPartOf>
                                </xsl:if>

                                <skos:notation><xsl:value-of select="@value"/></skos:notation>

<!--
XXX: Difference between SDMX 2.0 and SDMX 2.1
-->
                                <xsl:choose>
                                    <xsl:when test="structure:Name and structure:Description">
                                        <xsl:apply-templates select="structure:Name"/>
                                        <xsl:apply-templates select="structure:Description"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="structure:Description">
                                            <skos:prefLabel><xsl:call-template name="langTextNode"/></skos:prefLabel>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>

                                <xsl:apply-templates select="structure:Annotations/common:Annotation"/>
                            </rdf:Description>
                        </skos:hasTopConcept>
                    </xsl:for-each>
                </rdf:Description>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="HierarchicalCodelists">
        <xsl:for-each select="Structure/HierarchicalCodelists/structure:HierarchicalCodelist">
            <xsl:variable name="HierarchicalCodelistID" select="@id"/>
            <xsl:variable name="version" select="fn:getVersion(@version)"/>
            <xsl:variable name="hierarchicalCodeListURI" select="concat($code, $version, '/', @id)"/>

            <xsl:call-template name="provenance">
                <xsl:with-param name="provUsedA" select="resolve-uri(tokenize($xmlDocument, '/')[last()], $xmlDocumentBaseUri)"/>
                <xsl:with-param name="provGenerated" select="$hierarchicalCodeListURI"/>
                <xsl:with-param name="entityID" select="@id"/>
            </xsl:call-template>

            <rdf:Description rdf:about="{$hierarchicalCodeListURI}">
                <rdf:type rdf:resource="{$skos}Collection"/>

                <xsl:apply-templates select="@uri"/>
                <xsl:apply-templates select="@urn"/>
                <xsl:apply-templates select="@version"/>

                <skos:notation><xsl:value-of select="@id"/></skos:notation>
                <xsl:apply-templates select="structure:Name"/>
                <xsl:apply-templates select="structure:Description"/>


                <xsl:for-each select="structure:CodelistRef">
                    <xsl:variable name="codelist">
                        <xsl:choose>
                            <xsl:when test="structure:CodelistID">
                                <xsl:value-of select="structure:CodelistID"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="structure:Alias"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <dcterms:references rdf:resource="{concat($code, fn:getVersion(structure:Version), '/', $codelist)}"/>
                </xsl:for-each>

                <xsl:for-each select="structure:Hierarchy">
                    <skos:member>
                        <xsl:variable name="version" select="fn:getVersion(@version)"/>
                        <xsl:variable name="hierarchyURI" select="concat($code, $version, '/', @id)"/>

                        <rdf:Description rdf:about="{$hierarchyURI}">
                            <rdf:type rdf:resource="{$skos}Collection"/>
                            <rdf:type rdf:resource="{$xkos}ClassificationLevel"/>

                            <skos:notation><xsl:value-of select="@id"/></skos:notation>

                            <xsl:apply-templates select="structure:Name"/>

                            <xsl:apply-templates select="@urn"/>
                            <xsl:apply-templates select="@validFrom"/>
                            <xsl:apply-templates select="@validTo"/>
                            <xsl:apply-templates select="@version"/>

                            <xsl:for-each select="structure:CodeRef">
                                <skos:member>
                                    <xsl:call-template name="CodeRefs">
                                        <xsl:with-param name="HierarchicalCodelistID" select="$HierarchicalCodelistID"/>
                                    </xsl:call-template>
                                </skos:member>
                            </xsl:for-each>
                        </rdf:Description>
                    </skos:member>
                </xsl:for-each>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="CodeRefs">
        <xsl:param name="HierarchicalCodelistID"/>
        <xsl:param name="codeURIParent"/>

<!--
XXX:
"At a minimum, either a URN value (a valid SDMX Registry URN as specified in teh SDMX Registry Specification) must be supplied, or a CodelistAliasRef and a CodeID must be specified."
-->
        <xsl:variable name="CodeID" select="structure:CodeID"/>

<!--
FIXME:
This is a kind of a hack, works based on tested sample structures. Not guaranteed to work for all URNs. Alternatively, reconsider the data model given URNs
-->
        <xsl:variable name="CodelistAliasRef">
            <xsl:choose>
                <xsl:when test="structure:URN">
                    <xsl:variable name="structureURN" select="structure:URN"/>

                    <xsl:for-each select="distinct-values(/Structure/HierarchicalCodelists/structure:HierarchicalCodelist[@id = $HierarchicalCodelistID]/structure:CodelistRef/structure:CodelistID/text())">
                        <xsl:if test="contains($structureURN, .)">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="CodelistAliasRef" select="structure:CodelistAliasRef"/>

                    <xsl:variable name="CodelistID" select="/Structure/HierarchicalCodelists/structure:HierarchicalCodelist[@id = $HierarchicalCodelistID]/structure:CodelistRef[structure:Alias = $CodelistAliasRef]/structure:CodelistID"/>

                    <xsl:choose>
                        <xsl:when test="$CodelistID != ''">
                            <xsl:value-of select="$CodelistID"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$CodelistAliasRef"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


<!--
TODO:
"NodeAliasID allows for an ID to be assigned to the use of the particular code at that specific point in the hierarchy. This value is unique within the hierarchy being created, and is used to map the hierarchy against external structures."
-->

<!--
XXX:
* Doublecheck the exact relationship between an hierarchical list and a code list.
* Should the parent CodelistAliasRef/CodeID be prefixed to current CodelistAliasRef/CodeID?
-->

            <xsl:variable name="codelistVersion" select="/Structure/HierarchicalCodelists/structure:HierarchicalCodelist[@id = $HierarchicalCodelistID]/structure:CodelistRef[structure:Alias = $CodelistAliasRef]/structure:Version"/>

            <xsl:variable name="version" select="fn:getVersion(/Structure/CodeLists/structure:CodeList[@id = $CodelistAliasRef and @version = $codelistVersion])"/>

            <xsl:variable name="codeURI" select="concat($code, $version, '/', $CodelistAliasRef, $uriThingSeparator, $CodeID)"/>


            <rdf:Description rdf:about="{$codeURI}">
                <xsl:if test="$codeURIParent">
                    <xkos:isPartOf rdf:resource="{$codeURIParent}"/>
                </xsl:if>

                <xsl:if test="structure:ValidFrom">
                    <sdmx-concept:validFrom><xsl:value-of select="structure:ValidFrom"/></sdmx-concept:validFrom>
                </xsl:if>
                <xsl:if test="structure:ValidTo">
                    <sdmx-concept:validTo><xsl:value-of select="structure:ValidTo"/></sdmx-concept:validTo>
                </xsl:if>

                <xsl:if test="structure:Version">
                    <owl:versionInfo><xsl:value-of select="structure:Version"/></owl:versionInfo>
                </xsl:if>

                <xsl:for-each select="structure:CodeRef">
                    <xkos:hasPart>
                        <xsl:call-template name="CodeRefs">
                            <xsl:with-param name="HierarchicalCodelistID" select="$HierarchicalCodelistID"/>
                            <xsl:with-param name="codeURIParent" select="$codeURI"/>
                        </xsl:call-template>
                    </xkos:hasPart>
                </xsl:for-each>
            </rdf:Description>
    </xsl:template>


    <xsl:template name="DataSets">
        <xsl:variable name="DataSetID">
            <xsl:if test="*/*[local-name() = 'Header']/*[local-name() = 'DataSetID']">
                <xsl:value-of select="*/*[local-name() = 'Header']/*[local-name() = 'DataSetID']"/>
            </xsl:if>
        </xsl:variable>

        <xsl:for-each select="*/*[local-name() = 'DataSet']">
            <xsl:if test="*[local-name() = 'Series'] or */*[local-name() = 'Series'] or */*[local-name() = Group]/*[local-name() = 'Series']">
                <xsl:variable name="KeyFamilyRef">
                    <xsl:choose>
                        <xsl:when test="generic:KeyFamilyRef">
                            <xsl:value-of select="generic:KeyFamilyRef"/>
                        </xsl:when>
<!--
XXX: Fallback: KeyFamilyRef may not exist. But this is inaccurate if there are multiple KeyFamilies
-->
                        <xsl:otherwise>
                            <xsl:value-of select="$genericStructure/KeyFamilies/structure:KeyFamily[1]/@id"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="KeyFamily" select="$genericStructure/KeyFamilies/structure:KeyFamily[@id = $KeyFamilyRef]"/>

                <xsl:variable name="KeyFamilyAgencyID" select="$genericStructure/KeyFamilies/structure:KeyFamily[@id = $KeyFamilyRef]/@agencyID"/>

                <xsl:variable name="concepts" select="distinct-values($KeyFamily/structure:Components/*/@conceptRef)"/>

                <xsl:variable name="TimeDimensionConceptRef" select="distinct-values($KeyFamily/structure:Components/structure:TimeDimension/@conceptRef)"/>

                <xsl:variable name="PrimaryMeasureConceptRef" select="distinct-values($KeyFamily/structure:Components/structure:PrimaryMeasure/@conceptRef)"/>

                <xsl:variable name="SeriesKeyConceptsData" select="fn:createSeriesKeyComponentData($concepts, $KeyFamilyRef)"/>

<!-- FIXME: WTF did I just come up with every case combination for "datasetid"? -->
                <xsl:variable name="datasetID">
                    <xsl:choose>
                        <!-- from generic data -->
                        <xsl:when test="@datasetID">
                            <xsl:value-of select="@datasetID"/>
                        </xsl:when>
                        <!-- passed parameter -->
                        <xsl:when test="$dataSetID">
                            <xsl:value-of select="$dataSetID"/>
                        </xsl:when>
                        <!-- from compact data? -->
                        <xsl:when test="$DataSetID">
                            <xsl:value-of select="$DataSetID"/>
                        </xsl:when>
                        <!-- last resort -->
                        <xsl:otherwise>
                            <xsl:value-of select="$KeyFamilyRef"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="datasetURI">
                    <xsl:value-of select="$dataset"/>
                    <xsl:value-of select="$datasetID"/>
                </xsl:variable>

                <xsl:call-template name="provenance">
                    <xsl:with-param name="provUsedA" select="resolve-uri(tokenize($xmlDocument, '/')[last()], $xmlDocumentBaseUri)"/>
                    <xsl:with-param name="provUsedB" select="resolve-uri(tokenize($pathToGenericStructure, '/')[last()], $xmlDocumentBaseUri)"/>
                    <xsl:with-param name="provGenerated" select="$datasetURI"/>
                    <xsl:with-param name="entityID" select="$datasetID"/>
                </xsl:call-template>

                <rdf:Description rdf:about="{$datasetURI}">
                    <rdf:type rdf:resource="{$qb}DataSet"/>

                    <qb:structure rdf:resource="{$structure}{$KeyFamilyRef}"/>

                    <dcterms:identifier><xsl:value-of select="$datasetID"/></dcterms:identifier>

                    <xsl:call-template name="DataSetName">
                        <xsl:with-param name="datasetID" select="$datasetID"/>
                    </xsl:call-template>


    <!--
    XXX: do something about @keyFamilyURI?
    -->
                </rdf:Description>

                <xsl:for-each select="generic:Group">
    <!--
    XXX: This is currently a flat version. Needs to be reviewed.

    TODO: generic:Attributes - this is apparently repeated in the Series says the spec. In that case it is already being treated like a attachmentLevel at Observation.
    -->
                    <xsl:call-template name="Series">
                        <xsl:with-param name="KeyFamily" select="$KeyFamily" tunnel="yes"/>
                        <xsl:with-param name="KeyFamilyRef" select="$KeyFamilyRef" tunnel="yes"/>
                        <xsl:with-param name="KeyFamilyAgencyID" select="$KeyFamilyAgencyID" tunnel="yes"/>
                        <xsl:with-param name="datasetURI" select="$datasetURI" tunnel="yes"/>
                        <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData" tunnel="yes"/>
                        <xsl:with-param name="TimeDimensionConceptRef" select="$TimeDimensionConceptRef" tunnel="yes"/>
                        <xsl:with-param name="PrimaryMeasureConceptRef" select="$PrimaryMeasureConceptRef" tunnel="yes"/>
                    </xsl:call-template>
                </xsl:for-each>

                <xsl:call-template name="Series">
                    <xsl:with-param name="KeyFamily" select="$KeyFamily" tunnel="yes"/>
                    <xsl:with-param name="KeyFamilyRef" select="$KeyFamilyRef" tunnel="yes"/>
                    <xsl:with-param name="KeyFamilyAgencyID" select="$KeyFamilyAgencyID" tunnel="yes"/>
                    <xsl:with-param name="datasetURI" select="$datasetURI" tunnel="yes"/>
                    <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData" tunnel="yes"/>
                    <xsl:with-param name="TimeDimensionConceptRef" select="$TimeDimensionConceptRef" tunnel="yes"/>
                    <xsl:with-param name="PrimaryMeasureConceptRef" select="$PrimaryMeasureConceptRef" tunnel="yes"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="Series">
        <xsl:param name="KeyFamily" tunnel="yes"/>
        <xsl:param name="KeyFamilyRef" tunnel="yes"/>
        <xsl:param name="KeyFamilyAgencyID" tunnel="yes"/>
        <xsl:param name="datasetURI" tunnel="yes"/>
        <xsl:param name="SeriesKeyConceptsData" tunnel="yes"/>
        <xsl:param name="TimeDimensionConceptRef" tunnel="yes"/>
        <xsl:param name="PrimaryMeasureConceptRef" tunnel="yes"/>

        <xsl:for-each select="*[local-name() = 'Series']">
<!--
FIXME: Excluding 'FREQ' is a bit grubby?
Use FrequencyDimension="true" from KeyFamily Component
-->
            <xsl:variable name="Values" select="generic:SeriesKey/generic:Value"/>
            <xsl:variable name="ValuesWOFreq" select="$Values[lower-case(@concept) != 'freq']"/>
            <xsl:variable name="Group" select="$KeyFamily/structure:Components/structure:Group"/>

            <xsl:variable name="SeriesKeyValuesURI" select="string-join($Values[lower-case(@concept) != 'freq']/normalize-space(@value), $uriDimensionSeparator)"/>
            <xsl:variable name="DimensionValuesURI" select="string-join($Values/normalize-space(@value), $uriDimensionSeparator)"/>

            <xsl:if test="$Group and count($ValuesWOFreq) = count($Group/structure:DimensionRef)">
                <rdf:Description rdf:about="{$datasetURI}">
                    <qb:slice>
                        <rdf:Description rdf:about="{$slice}{$KeyFamilyRef}{$uriThingSeparator}{$SeriesKeyValuesURI}">
                            <rdf:type rdf:resource="{$qb}Slice"/>
                            <qb:sliceStructure rdf:resource="{concat($slice, $KeyFamilyRef, $uriThingSeparator, $Group/@id)}"/>
                            <xsl:for-each select="$ValuesWOFreq">
                                <xsl:variable name="concept" select="@concept"/>
                                <xsl:call-template name="ObsProperty">
                                    <xsl:with-param name="SeriesKeyConcept" select="$SeriesKeyConceptsData/*[lower-case(name()) = lower-case($concept)]"/>
                                    <xsl:with-param name="value" select="@value"/>
                                </xsl:call-template>
                            </xsl:for-each>

                            <xsl:for-each select="generic:Obs">
                                <xsl:variable name="ObsTime" select="replace(generic:Time, '\s+', '')"/>
                                <xsl:variable name="ObsTimeURI">
                                    <xsl:if test="$ObsTime">
                                        <xsl:value-of select="$uriDimensionSeparator"/><xsl:value-of select="$ObsTime"/>
                                    </xsl:if>
                                </xsl:variable>
                                <qb:observation>
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="$datasetURI"/><xsl:value-of select="$uriThingSeparator"/><xsl:value-of select="$DimensionValuesURI"/><xsl:value-of select="$ObsTimeURI"/>
                                    </xsl:attribute>
                                </qb:observation>
                            </xsl:for-each>
                        </rdf:Description>
                    </qb:slice>
                </rdf:Description>
            </xsl:if>
<!--
TODO:
"TextType provides for a set of language-specific alternates to be provided for any human-readable construct in the instance."

This is a one time retrieval but perhaps not necessary for the observations. Revisit.

        <xsl:variable name="PrimaryMeasureTextFormattextType">
            <xsl:value-of select="$genericStructure/KeyFamilies/structure:KeyFamily[@id = $KeyFamilyRef]/structure:Components/PrimaryMeasure/TextFormat/@textType"/>
        </xsl:variable>
-->

            <xsl:variable name="omitComponents">
                <xsl:for-each select="$ConfigOmitComponents/rdf:value">
                    <xsl:value-of select="lower-case(.)"/><xsl:text> </xsl:text>
                </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="GenericAttributes">
                <xsl:for-each select="generic:Attributes/generic:Value">
                    <xsl:variable name="concept" select="@concept"/>

                    <xsl:if test="not(contains($omitComponents, lower-case($concept)))">
                        <xsl:call-template name="ObsProperty">
                            <xsl:with-param name="SeriesKeyConcept" select="$SeriesKeyConceptsData/*[lower-case(name()) = lower-case($concept)]"/>
                            <xsl:with-param name="value" select="@value"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <xsl:for-each select="*[local-name() = 'Obs']">
                <xsl:variable name="ObsTime" select="replace(generic:Time, '\s+', '')"/>
                <xsl:variable name="ObsTimeURI">
                    <xsl:if test="$ObsTime">
                        <xsl:value-of select="$uriDimensionSeparator"/><xsl:value-of select="$ObsTime"/>
                    </xsl:if>
                </xsl:variable>

                <rdf:Description rdf:about="{$datasetURI}{$uriThingSeparator}{$DimensionValuesURI}{$ObsTimeURI}">
                    <rdf:type rdf:resource="{$qb}Observation"/>
                    <qb:dataSet rdf:resource="{$datasetURI}"/>

                    <xsl:for-each select="$Values">
                        <xsl:variable name="concept" select="@concept"/>
                        <xsl:call-template name="ObsProperty">
                            <xsl:with-param name="SeriesKeyConcept" select="$SeriesKeyConceptsData/*[lower-case(name()) = lower-case($concept)]"/>
                            <xsl:with-param name="value" select="@value"/>
                        </xsl:call-template>
                    </xsl:for-each>

                    <xsl:if test="$ObsTime != '' and $TimeDimensionConceptRef != ''">
                        <xsl:element name="property:{$TimeDimensionConceptRef}" namespace="{$property}{$SeriesKeyConceptsData/*[name() = $TimeDimensionConceptRef]}">

                            <xsl:variable name="resourceRefPeriod" select="fn:getResourceRefPeriod($ObsTime)"/>

                            <xsl:choose>
                                <xsl:when test="$resourceRefPeriod != ''">
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="$resourceRefPeriod"/>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="datatype" select="$SeriesKeyConceptsData/*[lower-case(name()) = lower-case($TimeDimensionConceptRef)]/@datatype"/>
                                    <xsl:if test="$datatype != ''">
                                        <xsl:call-template name="rdfDatatypeXSD">
                                            <xsl:with-param name="type" select="$datatype"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                    <xsl:value-of select="$ObsTime"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:if>

                    <xsl:for-each select="generic:ObsValue">
                        <xsl:element name="property:{$PrimaryMeasureConceptRef}" namespace="{$property}{$SeriesKeyConceptsData/*[name() = $PrimaryMeasureConceptRef]}">
                            <xsl:variable name="datatype" select="$SeriesKeyConceptsData/*[lower-case(name()) = lower-case($PrimaryMeasureConceptRef)]/@datatype"/>
                            <xsl:choose>
                                <xsl:when test="$datatype != ''">
                                    <xsl:call-template name="rdfDatatypeXSD">
                                        <xsl:with-param name="type" select="$datatype"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="rdfDatatypeXSD">
                                        <xsl:with-param name="type" select="fn:detectDatatype(@value)"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>

                            <xsl:value-of select="@value"/>
                        </xsl:element>
                    </xsl:for-each>

                    <xsl:for-each select="generic:Attributes/generic:Value">
                        <xsl:variable name="concept" select="@concept"/>

                        <xsl:if test="not(contains($omitComponents, lower-case($concept)))">
                            <xsl:call-template name="ObsProperty">
                                <xsl:with-param name="SeriesKeyConcept" select="$SeriesKeyConceptsData/*[lower-case(name()) = lower-case($concept)]"/>
                                <xsl:with-param name="value" select="@value"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>

                    <xsl:copy-of select="$GenericAttributes/*"/>
                </rdf:Description>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="ObsProperty">
        <xsl:param name="SeriesKeyConcept"/>
        <xsl:param name="value"/>

        <xsl:element name="property:{$SeriesKeyConcept/name()}" namespace="{$property}">
            <xsl:choose>
                <xsl:when test="$SeriesKeyConcept/@codelist != ''">
                    <xsl:attribute name="rdf:resource">
                        <xsl:choose>
                            <xsl:when test="lower-case(normalize-space($SeriesKeyConcept/@codelistAgency)) = 'sdmx'">

                                <xsl:variable name="codelistNormalized" select="fn:normalizeSDMXCodeListID($SeriesKeyConcept/@codelist)"/>
                                <xsl:variable name="SDMXConcept" select="$SDMXCode/skos:Concept[skos:notation = $value and @rdf:about = $SDMXCode/skos:ConceptScheme[skos:notation = $codelistNormalized][1]/skos:hasTopConcept/@rdf:resource]"/>
                                <xsl:value-of select="$SDMXConcept/@rdf:about"/>
                            </xsl:when>
        <!--
        FIXME: $urithingSeparator is already used in getComponentURI
        -->
                            <xsl:otherwise>
                                <xsl:value-of select="fn:getComponentURI('code', $SeriesKeyConcept/@codelistAgency)"/><xsl:text>/</xsl:text><xsl:value-of select="$SeriesKeyConcept/@codelistVersion"/><xsl:text>/</xsl:text><xsl:value-of select="$SeriesKeyConcept/@codelist"/><xsl:value-of select="$uriThingSeparator"/><xsl:value-of select="normalize-space($value)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$SeriesKeyConcept/@datatype != ''">
                        <xsl:call-template name="rdfDatatypeXSD">
                            <xsl:with-param name="type" select="$SeriesKeyConcept/@datatype"/>
                        </xsl:call-template>
                    </xsl:if>

                    <xsl:value-of select="$value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
