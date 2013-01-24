<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URI: http://csarven.ca/#i

    Description: XSLT for generic SDMX-ML to RDF Data Cube
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
    <xsl:variable name="genericStructure" select="document($pathToGenericStructure)/Structure"/>

<!--
TODO:
* Default to language when the structure or data doesn't contain xml:lang
* When agencyID="SDMX", fixed corresponding URIs within the SDMX namespace should be used. Sometimes codelistAgency or conceptSchemeAgency is not mentioned in the KeyFamily but the Codelist uses agencyID="SDMX". A first check might be to see if there is an agencyID set for the conceptRef or codelist
* Similarly consider what to do for agencyID's that's different than self agency and SDMX. Ideally it should use their full URI - needs to check registry?
* Consider detecting common datetime patterns and use a URI or datatypes
* Improve config for URI and thing separator
* isExternalReference
-->

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
            <xsl:variable name="id" select="fn:getAttributeValue(@id)"/>
            <xsl:variable name="agencyID" select="fn:getAttributeValue(@agencyID)"/>
            <xsl:variable name="dsdURI">
                <xsl:value-of select="$dataset"/>
                <xsl:value-of select="$id"/>
                <xsl:value-of select="$uriThingSeparator"/>
                <xsl:text>structure</xsl:text>
            </xsl:variable>

<!--
FIXME: $pathToGenericStructure should be replaced with an HTTP URI
-->
            <xsl:call-template name="provActivity">
                <xsl:with-param name="provUsedA" select="resolve-uri(tokenize($xmlDocument, '/')[last()], $xmlDocumentBaseUri)"/>
                <xsl:with-param name="provGenerated" select="$dsdURI"/>
            </xsl:call-template>

            <rdf:Description rdf:about="{$dsdURI}">
                <rdf:type rdf:resource="{$sdmx}DataStructureDefinition"/>
                <rdf:type rdf:resource="{$qb}DataStructureDefinition"/>
                <rdf:type rdf:resource="{$prov}Entity"/>
                <prov:wasAttributedTo rdf:resource="{$creator}"/>

<!-- TODO:
* Review these properties. Some are close enough to existing SDMX, some I made them up - they should be added to sdmx* vocabs perhpas, so, consider creating sdmx-concept URIs for isFinal/isExternalReference/validFrom/validTo ...?
-->
                <sdmx-concept:dsi><xsl:value-of select="$id"/></sdmx-concept:dsi>

                <sdmx-concept:mAgency><xsl:value-of select="$agencyID"/></sdmx-concept:mAgency>

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

                <xsl:call-template name="structureGroup"/>
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
                    <xsl:choose>
<!--
XXX:
Should we give any special treatment to TimeDimension even though qb currently doesn't?
-->
                        <xsl:when test="local-name() = 'Dimension' or local-name() = 'TimeDimension'">
                            <qb:dimension>
                                <rdf:Description rdf:about="{$property}{$conceptRef}">
                                    <rdf:type rdf:resource="{$qb}DimensionProperty"/>
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept>
                                        <rdf:Description rdf:about="{$concept}{$conceptRef}">
                                            <rdf:type resource="{$sdmx}{fn:getConceptRole(.)}"></rdf:type>
                                        </rdf:Description>
                                    </qb:concept>
                                    <xsl:call-template name="qbCodeListrdfsRange">
                                        <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData/*[name() = $conceptRef]" tunnel="yes"/>
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
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept>
                                        <rdf:Description rdf:about="{$concept}{$conceptRef}">
                                            <rdf:type resource="{$sdmx}{fn:getConceptRole(.)}"></rdf:type>
                                        </rdf:Description>
                                    </qb:concept>
                                    <xsl:call-template name="qbCodeListrdfsRange">
                                        <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData/*[name() = $conceptRef]" tunnel="yes"/>
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
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept>
                                        <rdf:Description rdf:about="{$concept}{$conceptRef}">
                                            <rdf:type resource="{$sdmx}{fn:getConceptRole(.)}"></rdf:type>
                                        </rdf:Description>
                                    </qb:concept>
                                    <xsl:call-template name="qbCodeListrdfsRange">
                                        <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData/*[name() = $conceptRef]" tunnel="yes"/>
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
    </xsl:template>


    <xsl:template name="structureGroup">
        <xsl:variable name="agencyID" select="ancestor-or-self::structure:KeyFamily/@agencyID"/>

        <xsl:for-each select="structure:Components/structure:Group">
            <xsl:variable name="id" select="fn:getAttributeValue(@id)"/>

            <qb:sliceKey>
                <rdf:Description rdf:about="{$slice}{$id}">
                    <rdf:type rdf:resource="{$qb}SliceKey"/>
                    <skos:notation><xsl:value-of select="$id"/></skos:notation>

                    <xsl:for-each select="structure:DimensionRef">
                        <qb:componentProperty rdf:resource="{$concept}{normalize-space(text())}"/>
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
        <xsl:variable name="id" select="fn:getAttributeValue(@id)"/>
        <xsl:variable name="agencyID" select="fn:getAttributeValue(@agencyID)"/>

        <xsl:variable name="uriValidFromToSeparator">
            <xsl:if test="@validFrom and @validTo">
                <xsl:value-of select="fn:getUriValidFromToSeparator(@validFrom, @validTo)"/>
            </xsl:if>
        </xsl:variable>

        <rdf:Description rdf:about="{$concept}{$id}{$uriValidFromToSeparator}">
<!--
XXX:
SDMX-ML actually differentiates ConceptScheme from CodeList. Add sdmx:ConceptScheme?
-->
            <rdf:type rdf:resource="{$skos}ConceptScheme"/>

            <xsl:apply-templates select="@uri"/>
            <xsl:apply-templates select="@urn"/>
            <xsl:apply-templates select="@version"/>

            <skos:notation><xsl:value-of select="$id"/></skos:notation>

            <xsl:apply-templates select="structure:Name"/>

            <xsl:for-each select="structure:Concept">
                <skos:hasTopConcept>
                    <xsl:call-template name="structureConcept">
                        <xsl:with-param name="ConceptSchemeID" select="$id"/>
                        <xsl:with-param name="ConceptSchemeIDAgencyID" select="$agencyID"/>
                    </xsl:call-template>
                </skos:hasTopConcept>
            </xsl:for-each>
        </rdf:Description>
    </xsl:template>


    <xsl:template name="structureConcept">
        <xsl:param name="ConceptSchemeID"/>
        <xsl:param name="ConceptSchemeIDAgencyID"/>

        <xsl:variable name="id" select="fn:getAttributeValue(@id)"/>
        <xsl:variable name="agencyID" select="fn:getAttributeValue(@agencyID)"/>

        <xsl:variable name="agencyID">
            <xsl:choose>
                <xsl:when test="$agencyID != ''">
                    <xsl:value-of select="$agencyID"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ConceptSchemeIDAgencyID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <rdf:Description rdf:about="{$concept}{$id}">
            <rdf:type rdf:resource="{$sdmx}Concept"/>
            <rdf:type rdf:resource="{$skos}Concept"/>

            <xsl:if test="$ConceptSchemeID">
                <skos:topConceptOf rdf:resource="{$concept}{$ConceptSchemeID}"/>
                <skos:inScheme rdf:resource="{$concept}{$ConceptSchemeID}"/>
            </xsl:if>

            <xsl:apply-templates select="@uri"/>
            <xsl:apply-templates select="@urn"/>
            <xsl:apply-templates select="@version"/>

            <skos:notation><xsl:value-of select="$id"/></skos:notation>

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
            <xsl:variable name="agencyID" select="lower-case(normalize-space(fn:getAttributeValue(@agencyID)))"/>

            <xsl:if test="$agencyID = lower-case(normalize-space($agency))">
                <xsl:variable name="id" select="fn:getAttributeValue(@id)"/>

                <xsl:variable name="uriValidFromToSeparator">
                    <xsl:if test="@validFrom and @validTo">
                        <xsl:value-of select="fn:getUriValidFromToSeparator(@validFrom, @validTo)"/>
                    </xsl:if>
                </xsl:variable>

                <rdf:Description rdf:about="{$code}/{$id}{$uriValidFromToSeparator}">
                    <rdf:type rdf:resource="{$sdmx}CodeList"/>
                    <rdf:type rdf:resource="{$skos}ConceptScheme"/>

                    <rdfs:seeAlso>
                        <rdf:Description rdf:about="{$class}{$id}{$uriValidFromToSeparator}">
                            <rdf:type rdf:resource="{$rdfs}Class"/>
                            <rdf:type rdf:resource="{$owl}Class"/>
                            <rdfs:subClassOf rdf:resource="{$skos}Concept"/>
                            <rdfs:seeAlso rdf:resource="{$code}{$id}{$uriValidFromToSeparator}"/>
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
                        <skos:hasTopConcept>
                            <rdf:Description rdf:about="{$code}/{$id}{$uriThingSeparator}{@value}">
                                <rdf:type rdf:resource="{$sdmx}Concept"/>
                                <rdf:type rdf:resource="{$skos}Concept"/>
                                <rdf:type rdf:resource="{$class}{$id}{$uriValidFromToSeparator}"/>
                                <skos:topConceptOf rdf:resource="{$code}{$uriThingSeparator}{$id}{$uriValidFromToSeparator}"/>
                                <skos:inScheme rdf:resource="{$code}{$uriThingSeparator}{$id}{$uriValidFromToSeparator}"/>

                                <xsl:apply-templates select="@urn"/>

                                <xsl:if test="@parentCode">
                                    <skos:broader>
                                        <rdf:Description rdf:about="{$code}/{$id}{$uriThingSeparator}{@parentCode}">
                                            <skos:narrower rdf:resource="{$code}/{$id}{$uriThingSeparator}{@value}"/>
                                        </rdf:Description>
                                    </skos:broader>
                                </xsl:if>

                                <skos:notation><xsl:value-of select="@value"/></skos:notation>
                                <xsl:apply-templates select="structure:Description"/>

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
            <xsl:variable name="id" select="fn:getAttributeValue(@id)"/>
            <xsl:variable name="agencyID" select="fn:getAttributeValue(@agencyID)"/>

            <xsl:variable name="uriValidFromToSeparator">
                <xsl:if test="@validFrom and @validTo">
                    <xsl:value-of select="fn:getUriValidFromToSeparator(@validFrom, @validTo)"/>
                </xsl:if>
            </xsl:variable>

            <rdf:Description rdf:about="{$code}{$id}{$uriValidFromToSeparator}">
                <rdf:type rdf:resource="{$skos}Collection"/>

                <xsl:apply-templates select="@uri"/>
                <xsl:apply-templates select="@urn"/>
                <xsl:apply-templates select="@version"/>

                <skos:notation><xsl:value-of select="$id"/></skos:notation>
                <xsl:apply-templates select="structure:Name"/>
                <xsl:apply-templates select="structure:Description"/>

                <xsl:for-each select="structure:CodelistRef">
                    <dcterms:references rdf:resource="{$code}{structure:CodelistID}"/>
                </xsl:for-each>

                <xsl:for-each select="structure:Hierarchy">
                    <xsl:variable name="HierarchyID" select="@id"/>

                    <xkos:hasPart>
                        <xsl:variable name="uriValidFromToHierarchySeparator">
                            <xsl:if test="@validFrom and @validTo">
                                <xsl:value-of select="fn:getUriValidFromToSeparator(@validFrom, @validTo)"/>
                            </xsl:if>
                        </xsl:variable>

                        <rdf:Description rdf:about="{$code}{$uriValidFromToHierarchySeparator}{$uriThingSeparator}{$HierarchyID}">
                            <rdf:type rdf:resource="{$skos}Collection"/>
                            <skos:notation><xsl:value-of select="$id"/></skos:notation>

                            <xkos:isPartOf rdf:resource="{$code}{$id}{$uriValidFromToSeparator}"/>

                            <xsl:apply-templates select="structure:Name"/>

                            <xsl:apply-templates select="@urn"/>
                            <xsl:apply-templates select="@validFrom"/>
                            <xsl:apply-templates select="@validTo"/>
                            <xsl:apply-templates select="@version"/>

                            <xsl:call-template name="CodeRefs">
                                <xsl:with-param name="HierarchicalCodelistID" select="$id"/>
                                <xsl:with-param name="agencyID" select="$agencyID"/>
                            </xsl:call-template>
                        </rdf:Description>
                    </xkos:hasPart>
                </xsl:for-each>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="CodeRefs">
        <xsl:param name="HierarchicalCodelistID"/>
        <xsl:param name="CodelistAliasRef_parent"/>
        <xsl:param name="CodeID_parent"/>
        <xsl:param name="agencyID"/>

        <xsl:for-each select="structure:CodeRef">
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

                        <xsl:value-of select="/Structure/HierarchicalCodelists/structure:HierarchicalCodelist[@id = $HierarchicalCodelistID]/structure:CodelistRef[structure:Alias = $CodelistAliasRef]/structure:CodelistID/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

<!--
XXX:
Dirty?
-->
            <xsl:variable name="agencyID">
                <xsl:choose>
                    <xsl:when test="structure:URN">
                        <xsl:variable name="structureURN" select="structure:URN"/>

                        <xsl:variable name="AgencyID" select="/Structure/HierarchicalCodelists[@id = $HierarchicalCodelistID]/structure:HierarchicalCodelist/structure:CodelistRef"/>

                        <xsl:for-each select="distinct-values(/Structure/HierarchicalCodelists[@id = $HierarchicalCodelistID]/structure:HierarchicalCodelist/structure:CodelistRef/structure:CodelistID/text())">
                            <xsl:variable name="CodelistID" select="."/>

                            <xsl:if test="contains($structureURN, $CodelistID)">
                                <xsl:value-of select="distinct-values($AgencyID[structure:CodelistID = $CodelistID]/structure:AgencyID)[1]"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$agencyID"/>
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
* Consider changing skos:narrower, skos:broader to xkos:hasPart, xkos:isPartOf
-->
            <xkos:hasPart>
                <rdf:Description rdf:about="{$code}/{$CodelistAliasRef}{$uriThingSeparator}{$CodeID}">
                    <xsl:if test="$CodelistAliasRef_parent and $CodeID_parent">
                        <xkos:isPartOf rdf:resource="{$code}/{$CodelistAliasRef_parent}{$uriThingSeparator}{$CodeID_parent}"/>
                    </xsl:if>

                    <xsl:if test="structure:ValidFrom">
                        <sdmx-concept:validFrom><xsl:value-of select="structure:ValidFrom"/></sdmx-concept:validFrom>
                    </xsl:if>
                    <xsl:if test="structure:ValidTo">
                        <sdmx-concept:validTo><xsl:value-of select="structure:ValidTo"/></sdmx-concept:validTo>
                    </xsl:if>

                    <xsl:apply-templates select="@version"/>

                    <xsl:call-template name="CodeRefs">
                        <xsl:with-param name="HierarchicalCodelistID" select="$HierarchicalCodelistID"/>
                        <xsl:with-param name="CodelistAliasRef_parent" select="$CodelistAliasRef"/>
                        <xsl:with-param name="CodeID_parent" select="$CodeID"/>
                        <xsl:with-param name="agencyID" select="$agencyID"/>
                    </xsl:call-template>
                </rdf:Description>
            </xkos:hasPart>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="DataSets">
        <xsl:for-each select="*/*[local-name() = 'DataSet']">
            <xsl:variable name="KeyFamilyRef">
                <xsl:choose>
                    <xsl:when test="generic:KeyFamilyRef">
                        <xsl:value-of select="generic:KeyFamilyRef"/>
                    </xsl:when>
<!--
XXX: Fallback: KeyfamilyRef may not exist. But this is inaccurate if there are multiple KeyFamilies
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


            <xsl:variable name="datasetURI">
                <xsl:value-of select="$dataset"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$KeyFamilyRef"/>
            </xsl:variable>

            <xsl:call-template name="provActivity">
                <xsl:with-param name="provUsedA" select="resolve-uri(tokenize($xmlDocument, '/')[last()], $xmlDocumentBaseUri)"/>
                <xsl:with-param name="provUsedB" select="resolve-uri(tokenize($pathToGenericStructure, '/')[last()], $xmlDocumentBaseUri)"/>
                <xsl:with-param name="provGenerated" select="$datasetURI"/>
            </xsl:call-template>

            <rdf:Description rdf:about="{$datasetURI}">
                <rdf:type rdf:resource="{$qb}DataSet"/>
                <rdf:type rdf:resource="{$prov}Entity"/>
                <prov:wasAttributedTo rdf:resource="{$creator}"/>

                <qb:structure rdf:resource="{$dataset}{$KeyFamilyAgencyID}/{$KeyFamilyRef}{$uriThingSeparator}structure"/>
                <xsl:if test="@datasetID">
                    <skos:notation><xsl:value-of select="@datasetID"/></skos:notation>
                </xsl:if>

<!--
XXX: do something about @keyFamilyURI?
-->
            </rdf:Description>

            <xsl:for-each select="generic:Group">
<!--
XXX: This is currently a flat version. Needs to be reviewed.

TODO: generic:Attributes - this is apparently repeated in the Series says the spec. In that case it is already being treated like a attachmentLevel at Observation.
-->
                <xsl:call-template name="GenericSeries">
                    <xsl:with-param name="KeyFamily" select="$KeyFamily" tunnel="yes"/>
                    <xsl:with-param name="KeyFamilyRef" select="$KeyFamilyRef" tunnel="yes"/>
                    <xsl:with-param name="KeyFamilyAgencyID" select="$KeyFamilyAgencyID" tunnel="yes"/>
                    <xsl:with-param name="datasetURI" select="$datasetURI" tunnel="yes"/>
                    <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData" tunnel="yes"/>
                    <xsl:with-param name="TimeDimensionConceptRef" select="$TimeDimensionConceptRef" tunnel="yes"/>
                    <xsl:with-param name="PrimaryMeasureConceptRef" select="$PrimaryMeasureConceptRef" tunnel="yes"/>
                </xsl:call-template>
            </xsl:for-each>

            <xsl:call-template name="GenericSeries">
                <xsl:with-param name="KeyFamily" select="$KeyFamily" tunnel="yes"/>
                <xsl:with-param name="KeyFamilyRef" select="$KeyFamilyRef" tunnel="yes"/>
                <xsl:with-param name="KeyFamilyAgencyID" select="$KeyFamilyAgencyID" tunnel="yes"/>
                <xsl:with-param name="datasetURI" select="$datasetURI" tunnel="yes"/>
                <xsl:with-param name="SeriesKeyConceptsData" select="$SeriesKeyConceptsData" tunnel="yes"/>
                <xsl:with-param name="TimeDimensionConceptRef" select="$TimeDimensionConceptRef" tunnel="yes"/>
                <xsl:with-param name="PrimaryMeasureConceptRef" select="$PrimaryMeasureConceptRef" tunnel="yes"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="GenericSeries">
        <xsl:param name="KeyFamily" tunnel="yes"/>
        <xsl:param name="KeyFamilyRef" tunnel="yes"/>
        <xsl:param name="KeyFamilyAgencyID" tunnel="yes"/>
        <xsl:param name="datasetURI" tunnel="yes"/>
        <xsl:param name="SeriesKeyConceptsData" tunnel="yes"/>
        <xsl:param name="TimeDimensionConceptRef" tunnel="yes"/>
        <xsl:param name="PrimaryMeasureConceptRef" tunnel="yes"/>

        <xsl:for-each select="generic:Series">
<!--
FIXME: Excluding 'FREQ' is a bit grubby?
-->
            <xsl:variable name="Values" select="generic:SeriesKey/generic:Value"/>
            <xsl:variable name="ValuesWOFreq" select="$Values[lower-case(@concept) != 'freq']"/>
            <xsl:variable name="Group" select="$KeyFamily/structure:Components/structure:Group"/>

            <xsl:variable name="SeriesKeyValuesURI" select="string-join($Values[lower-case(@concept) != 'freq']/normalize-space(@value), $uriDimensionSeparator)"/>
            <xsl:variable name="DimensionValuesURI" select="string-join($Values/normalize-space(@value), $uriDimensionSeparator)"/>

            <xsl:if test="count($ValuesWOFreq) = count($Group/structure:DimensionRef)">
                <rdf:Description rdf:about="{$datasetURI}">
                    <qb:slice>
                        <rdf:Description rdf:about="{$slice}{$KeyFamilyRef}{$uriThingSeparator}{$SeriesKeyValuesURI}">
                            <rdf:type rdf:resource="{$qb}Slice"/>
                            <qb:sliceStructure rdf:resource="{fn:getSliceKey($KeyFamilyAgencyID, $Group)}"/>
                            <xsl:for-each select="$ValuesWOFreq">
                                <xsl:variable name="concept" select="@concept"/>
                                <xsl:call-template name="ObsProperty">
                                    <xsl:with-param name="SeriesKeyConcept" select="$SeriesKeyConceptsData/*[name() = $concept]"/>
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

            <xsl:variable name="GenericAttributes">
                <xsl:for-each select="generic:Attributes/generic:Value">
                    <xsl:variable name="concept" select="@concept"/>
                    <xsl:call-template name="ObsProperty">
                        <xsl:with-param name="SeriesKeyConcept" select="$SeriesKeyConceptsData/*[name() = $concept]"/>
                        <xsl:with-param name="value" select="@value"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:variable>

            <xsl:for-each select="generic:Obs">
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
                            <xsl:with-param name="SeriesKeyConcept" select="$SeriesKeyConceptsData/*[name() = $concept]"/>
                            <xsl:with-param name="value" select="@value"/>
                        </xsl:call-template>
                    </xsl:for-each>

                    <xsl:if test="$ObsTime != '' and $TimeDimensionConceptRef != ''">
                        <xsl:element name="property:{$TimeDimensionConceptRef}" namespace="{$property}{$SeriesKeyConceptsData/*[name() = $TimeDimensionConceptRef]/@conceptAgencyURI}">
                            <xsl:variable name="datatype" select="$SeriesKeyConceptsData/*[name() = $TimeDimensionConceptRef]/@datatype"/>
                            <xsl:if test="$datatype != ''">
                                <xsl:call-template name="rdfDatatypeXSD">
                                    <xsl:with-param name="type" select="$datatype"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:value-of select="$ObsTime"/>
                        </xsl:element>
                    </xsl:if>

                    <xsl:for-each select="generic:ObsValue">
                        <xsl:element name="property:{$PrimaryMeasureConceptRef}" namespace="{$property}{$SeriesKeyConceptsData/*[name() = $PrimaryMeasureConceptRef]/@conceptAgencyURI}">
                            <xsl:variable name="datatype" select="$SeriesKeyConceptsData/*[name() = $PrimaryMeasureConceptRef]/@datatype"/>
                            <xsl:if test="$datatype != ''">
                                <xsl:call-template name="rdfDatatypeXSD">
                                    <xsl:with-param name="type" select="$datatype"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:value-of select="@value"/>
                        </xsl:element>
                    </xsl:for-each>

                    <xsl:for-each select="generic:Attributes/generic:Value">
                        <xsl:variable name="concept" select="@concept"/>
                        <xsl:call-template name="ObsProperty">
                            <xsl:with-param name="SeriesKeyConcept" select="$SeriesKeyConceptsData/*[name() = $concept]"/>
                            <xsl:with-param name="value" select="@value"/>
                        </xsl:call-template>
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
                        <xsl:value-of select="fn:getComponentURI('code', $SeriesKeyConcept/@codelistAgency)"/><xsl:value-of select="$SeriesKeyConcept/@codelist"/><xsl:value-of select="$uriThingSeparator"/><xsl:value-of select="$value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
