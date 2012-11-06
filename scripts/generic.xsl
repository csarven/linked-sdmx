<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i

    Description: XSLT for generic SDMX-ML to RDF Data Cube structure
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:fn="http://270a.info/xpath-function/"
    xmlns:wgs="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
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

    xmlns:property="http://example.org/property/"

    xpath-default-namespace="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message"
    exclude-result-prefixes="xsl fn structure message generic"
    >

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="lang"/>
    <xsl:param name="base"/>
    <xsl:param name="pathToGenericStructure"/>
<!--
TODO:
* Consider offering an option to use human readable URIs e.g., world-development-indicators (from Header::Name) instead of WDI
* Decide whether to leave the string cases as is or change e.g., lowercased, separated by dash
* Default to language when the structure or data doesn't contain xml:lang
* Option to use slash or hash URIs
* Options to pass for each URI path component
* Consider what to do when the SDMX-ML is well-formed but doesn't exactly follow the intended use.
-->

    <xsl:variable name="rdf">http://www.w3.org/1999/02/22-rdf-syntax-ns#</xsl:variable>
    <xsl:variable name="xsd">http://www.w3.org/2001/XMLSchema#</xsl:variable>
    <xsl:variable name="qb">http://purl.org/linked-data/cube#</xsl:variable>
    <xsl:variable name="skos">http://www.w3.org/2004/02/skos/core#</xsl:variable>
    <xsl:variable name="sdmx">http://purl.org/linked-data/sdmx#</xsl:variable>

    <xsl:variable name="baseuri">
        <xsl:choose>
            <xsl:when test="$base = ''">
                <xsl:text>http://example.org/</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$base"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="concept">
        <xsl:value-of select="$baseuri"/><xsl:text>concept/</xsl:text>
    </xsl:variable>

    <xsl:variable name="code">
        <xsl:value-of select="$baseuri"/><xsl:text>code/</xsl:text>
    </xsl:variable>

    <xsl:variable name="property">
        <xsl:value-of select="$baseuri"/><xsl:text>property/</xsl:text>
    </xsl:variable>

    <xsl:variable name="dataset">
        <xsl:value-of select="$baseuri"/><xsl:text>dataset/</xsl:text>
    </xsl:variable>

    <xsl:template match="/">
<!--<xsl:message>-->
<!--<xsl:text>base: </xsl:text><xsl:value-of select="$base"/>-->
<!--<xsl:text>baseuri: </xsl:text><xsl:value-of select="$baseuri"/>-->
<!--</xsl:message>-->

        <rdf:RDF>
<!--            <xsl:attribute name="xmlns:property" select="$property"/>-->

            <xsl:call-template name="KeyFamily"/>

            <xsl:call-template name="Concepts"/>

            <xsl:call-template name="CodeLists"/>

            <xsl:call-template name="HierarchicalCodelists"/>

            <xsl:call-template name="DataSets"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="KeyFamily">
        <xsl:for-each select="Structure/KeyFamilies/structure:KeyFamily">
<!--
TODO:
Merge these. Change it to xsl:function
-->
            <xsl:variable name="id">
                <xsl:value-of select="fn:getAttributeValue(@id)"/>
            </xsl:variable>
            <xsl:variable name="agencyID">
                <xsl:value-of select="fn:getAttributeValue(@agencyID)"/>
            </xsl:variable>

            <xsl:variable name="agencyIDPath">
                <xsl:if test="$agencyID != ''">
                    <xsl:value-of select="$agencyID"/><xsl:text>/</xsl:text>
                </xsl:if>
            </xsl:variable>

            <rdf:Description rdf:about="{$dataset}{$agencyIDPath}{$id}/structure">
                <rdf:type rdf:resource="{$sdmx}DataStructureDefinition"/>
                <rdf:type rdf:resource="{$qb}DataStructureDefinition"/>

<!-- TODO:
* Review these properties. Some are close enough to existing SDMX, some I made them up - they should be added to sdmx* vocabs perhpas, so, consider creating sdmx-concept URIs for dsi/mAgency/isFinal/isExternalReference/validFrom/validTo ...?
-->
                <sdmx-concept:dsi><xsl:value-of select="$id"/></sdmx-concept:dsi>

                <sdmx-concept:mAgency><xsl:value-of select="$agencyID"/></sdmx-concept:mAgency>

                <xsl:if test="@version">
                    <sdmx-concept:dataRev><xsl:value-of select="@version"/></sdmx-concept:dataRev>
                </xsl:if>

                <xsl:if test="@uri">
                    <rdfs:isDefinedBy rdf:resource="{@uri}"/>
                </xsl:if>

                <xsl:if test="@urn">
                    <dcterms:identifier rdf:resource="{@urn}"/>
                </xsl:if>

                <xsl:if test="@isFinal">
                    <sdmx-concept:isFinal rdf:datatype="{$xsd}boolean"><xsl:value-of select="@isFinal"/></sdmx-concept:isFinal>
                </xsl:if>

<!--
XXX: "If the isExternalReference attribute is true, then the uri attribute must be provided, giving a location where a valid structure message can be found containing the full details of the key family."

Decide whether this should be omitted.
-->
                <xsl:if test="@isExternalReference">
                    <sdmx-concept:isExternalReference rdf:datatype="{$xsd}boolean"><xsl:value-of select="@isExternalReference"/></sdmx-concept:isExternalReference>
                </xsl:if>

<!--
TODO: These should have datatypes

XXX: dcterms:valid could be used along with gregorian-interval but 1) we don't know the format of these dates and 2) whether both will be supplied. Probably simpler to leave them separate.
-->
                <xsl:if test="@validFrom">
                    <sdmx-concept:validFrom><xsl:value-of select="@validFrom"/></sdmx-concept:validFrom>
                </xsl:if>

                <xsl:if test="@validTo">
                    <sdmx-concept:validTo><xsl:value-of select="@validTo"/></sdmx-concept:validTo>
                </xsl:if>


                <xsl:apply-templates select="structure:Name"/>

                <xsl:apply-templates select="structure:Description"/>

                <xsl:call-template name="structureComponents">
                    <xsl:with-param name="agencyIDPath" select="$agencyIDPath"/>
                </xsl:call-template>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>



    <xsl:template match="structure:Name">
        <skos:prefLabel>
            <xsl:call-template name="langTextNode"/>
        </skos:prefLabel>
    </xsl:template>

    <xsl:template match="structure:Description">
        <skos:definition>
            <xsl:call-template name="langTextNode"/>
        </skos:definition>
    </xsl:template>


    <xsl:template name="structureComponents">
<!--<xsl:message>-->
<!--<xsl:text>local-name(): </xsl:text><xsl:value-of select="local-name()"/>-->
<!--</xsl:message>-->

        <xsl:param name="agencyIDPath"/>

        <xsl:for-each select="structure:Components/*">
            <qb:component>
                <qb:ComponentSpecification>
                    <xsl:choose>
<!--
XXX:
Should we give any special treatment to TimeDimension even though qb currently doesn't?
-->
                        <xsl:when test="local-name() = 'Dimension' or local-name() = 'TimeDimension'">
                            <qb:dimension>
                                <rdf:Description rdf:about="{$property}{$agencyIDPath}{@conceptRef}/">
                                    <rdf:type rdf:resource="{$qb}DimensionProperty"/>
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept rdf:resource="{$concept}{$agencyIDPath}{@conceptRef}"/>
                                </rdf:Description>
                            </qb:dimension>

                            <qb:order rdf:datatype="{$xsd}integer">
<!--
XXX: Order matters but consider the case when XML doesn't list all dimensions one after another. It won't be sequential (skips numbers)
-->
                                <xsl:value-of select="position()"/>
                            </qb:order>

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
                                <rdf:Description rdf:about="{$property}{$agencyIDPath}{@conceptRef}">
                                    <rdf:type rdf:resource="{$qb}MeasureProperty"/>
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept rdf:resource="{$concept}{$agencyIDPath}{@conceptRef}"/>
                                </rdf:Description>
                            </qb:measure>
                        </xsl:when>

<!--
TODO:
-->
                        <xsl:when test="local-name() = 'CrossSectionalMeasure'">
                        </xsl:when>
<!--
TODO:
This is like qb:Slice
-->
                        <xsl:when test="local-name() = 'Group'">
                        </xsl:when>

                        <xsl:when test="local-name() = 'Attribute'">
                            <qb:attribute>
                                <rdf:Description rdf:about="{$property}{$agencyIDPath}{@conceptRef}">
                                    <rdf:type rdf:resource="{$qb}AttributeProperty"/>
                                    <rdf:type rdf:resource="{$rdf}Property"/>
                                    <qb:concept rdf:resource="{$concept}{$agencyIDPath}{@conceptRef}"/>                         
                                </rdf:Description>
                            </qb:attribute>

                            <xsl:choose>
                                <xsl:when test="@attachmentLevel = 'DataSet'">
                                    <qb:componentAttachment rdf:resource="{$qb}DataSet"/>
                                </xsl:when>
                                <xsl:when test="@attachmentLevel = 'Group'">
                                    <qb:componentAttachment rdf:resource="{$qb}Group"/>
                                </xsl:when>
                                <xsl:when test="@attachmentLevel = 'Series'">
<!--
XXX: This might be attached to qb:Dimension?
-->
                                    <qb:componentAttachment rdf:resource="{$qb}Series"/>
                                </xsl:when>

                                <xsl:otherwise>
                                    <qb:componentAttachment rdf:resource="{$qb}Observation"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:message>
                                <xsl:text>FIXME: Unknown local-name() = '</xsl:text><xsl:value-of select="local-name()"/><xsl:text>' to use for qb:component.</xsl:text>
                            </xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </qb:ComponentSpecification>
            </qb:component>
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
        <xsl:variable name="id">
            <xsl:value-of select="fn:getAttributeValue(@id)"/>
        </xsl:variable>
        <xsl:variable name="agencyID">
            <xsl:value-of select="fn:getAttributeValue(@agencyID)"/>
        </xsl:variable>

        <xsl:variable name="agencyIDPath">
            <xsl:if test="$agencyID != ''">
                <xsl:value-of select="$agencyID"/><xsl:text>/</xsl:text>
            </xsl:if>
        </xsl:variable>


        <rdf:Description rdf:about="{$concept}{$agencyIDPath}{$id}">
<!--
XXX:
SDMX-ML actually differentiates ConceptScheme from CodeList. Add sdmx:ConceptScheme?
-->
            <rdf:type rdf:resource="{$skos}ConceptScheme"/>

            <xsl:if test="@uri">
                <rdfs:isDefinedBy rdf:resource="{@uri}"/>
            </xsl:if>
            <xsl:if test="@urn">
                <dcterms:identifier rdf:resource="{@urn}"/>
            </xsl:if>

            <skos:notation><xsl:value-of select="$id"/></skos:notation>

            <xsl:apply-templates select="structure:Name"/>

            <xsl:for-each select="structure:Concept">
                <skos:hasTopConcept>
                    <xsl:call-template name="structureConcept">
                        <xsl:with-param name="ConceptSchemeID" select="$id"/>
                    </xsl:call-template>
                </skos:hasTopConcept>
            </xsl:for-each>
        </rdf:Description>
    </xsl:template>


    <xsl:template name="structureConcept">
        <xsl:param name="ConceptSchemeID"/>

        <xsl:variable name="id">
            <xsl:value-of select="fn:getAttributeValue(@id)"/>
        </xsl:variable>
        <xsl:variable name="agencyID">
            <xsl:value-of select="fn:getAttributeValue(@agencyID)"/>
        </xsl:variable>

        <xsl:variable name="agencyIDPath">
            <xsl:if test="$agencyID != ''">
                <xsl:value-of select="$agencyID"/><xsl:text>/</xsl:text>
            </xsl:if>
        </xsl:variable>

        <rdf:Description rdf:about="{$concept}{$agencyIDPath}{$id}">
            <rdf:type rdf:resource="{$sdmx}Concept"/>
            <rdf:type rdf:resource="{$skos}Concept"/>

            <xsl:if test="$ConceptSchemeID">
                <skos:topConceptOf rdf:resource="{$concept}{$agencyIDPath}{$ConceptSchemeID}"/>
                <skos:inScheme rdf:resource="{$concept}{$agencyIDPath}{$ConceptSchemeID}"/>
            </xsl:if>

            <xsl:if test="@uri">
                <rdfs:isDefinedBy rdf:resource="{@uri}"/>
            </xsl:if>
            <xsl:if test="@urn">
                <dcterms:identifier rdf:resource="{@urn}"/>
            </xsl:if>

            <skos:notation><xsl:value-of select="$id"/></skos:notation>

            <xsl:apply-templates select="structure:Name"/>

            <xsl:apply-templates select="structure:Description"/>
        </rdf:Description>
    </xsl:template>



    <xsl:template name="CodeLists">
        <xsl:for-each select="Structure/CodeLists/structure:CodeList">
            <xsl:variable name="id">
                <xsl:value-of select="fn:getAttributeValue(@id)"/>
            </xsl:variable>
            <xsl:variable name="agencyID">
                <xsl:value-of select="fn:getAttributeValue(@agencyID)"/>
            </xsl:variable>

            <xsl:variable name="agencyIDPath">
                <xsl:if test="$agencyID != ''">
                    <xsl:value-of select="$agencyID"/><xsl:text>/</xsl:text>
                </xsl:if>
            </xsl:variable>

            <rdf:Description rdf:about="{$code}{$agencyIDPath}{$id}">
                <rdf:type rdf:resource="{$sdmx}CodeList"/>

                <xsl:if test="@uri">
                    <rdfs:isDefinedBy rdf:resource="{@uri}"/>
                </xsl:if>

                <skos:notation><xsl:value-of select="$id"/></skos:notation>
                <xsl:apply-templates select="structure:Name"/>

                <xsl:for-each select="structure:Code">
                    <skos:hasTopConcept>
                        <rdf:Description rdf:about="{$code}{$agencyIDPath}{$id}/{@value}">
                            <rdf:type rdf:resource="{$sdmx}Concept"/>
                            <rdf:type rdf:resource="{$skos}Concept"/>
                            <rdf:type rdf:resource="{$code}{$agencyIDPath}{$id}"/>
                            <skos:topConceptOf rdf:resource="{$code}{$agencyIDPath}{$id}"/>
                            <skos:inScheme rdf:resource="{$code}{$agencyIDPath}{$id}"/>

                            <xsl:if test="@urn">
                                <dcterms:identifier rdf:resource="{@urn}"/>
                            </xsl:if>

                            <xsl:if test="@parentCode">
                                <skos:broader>
                                    <rdf:Description rdf:about="{$code}{$agencyIDPath}{$id}/{@parentCode}">
                                        <skos:narrower rdf:resource="{$code}{$agencyIDPath}{$id}/{@value}"/>
                                    </rdf:Description>
                                </skos:broader>
                            </xsl:if>

                            <skos:notation><xsl:value-of select="@value"/></skos:notation>
                            <xsl:apply-templates select="structure:Description"/>
                        </rdf:Description>
                    </skos:hasTopConcept>
                </xsl:for-each>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="HierarchicalCodelists">
        <xsl:for-each select="Structure/HierarchicalCodelists/structure:HierarchicalCodelist">
            <xsl:variable name="id">
                <xsl:value-of select="fn:getAttributeValue(@id)"/>
            </xsl:variable>
            <xsl:variable name="agencyID">
                <xsl:value-of select="fn:getAttributeValue(@agencyID)"/>
            </xsl:variable>

            <xsl:variable name="agencyIDPath">
                <xsl:if test="$agencyID != ''">
                    <xsl:value-of select="$agencyID"/><xsl:text>/</xsl:text>
                </xsl:if>
            </xsl:variable>

            <rdf:Description rdf:about="{$code}{$agencyIDPath}{$id}">
                <rdf:type rdf:resource="{$sdmx}CodeList"/>

                <xsl:if test="@uri">
                    <rdfs:isDefinedBy rdf:resource="{@uri}"/>
                </xsl:if>
                <xsl:if test="@urn">
                    <dcterms:identifier rdf:resource="{@urn}"/>
                </xsl:if>

                <skos:notation><xsl:value-of select="$id"/></skos:notation>
                <xsl:apply-templates select="structure:Name"/>
                <xsl:apply-templates select="structure:Description"/>

                <xsl:for-each select="structure:CodelistRef">
<!--
XXX:
The difference between structure:Alias and structure:CodelistID is not entirely clear. Looking at the sample structure data thus far, it is not clear either because one or the other is used. So, I'm putting both of these here, where one or the other will be used in practice even though both could exist.
-->
                    <xsl:if test="structure:Alias">
                        <dcterms:references rdf:resource="{$code}{$agencyIDPath}{structure:Alias}"/>
                    </xsl:if>

                    <xsl:if test="structure:CodelistID">
                        <dcterms:references rdf:resource="{$code}{$agencyIDPath}{structure:CodelistID}"/>
                    </xsl:if>
                </xsl:for-each>

                <xsl:for-each select="structure:Hierarchy">
                    <xsl:call-template name="CodeRefs">
                        <xsl:with-param name="agencyIDPath" select="$agencyIDPath"/>
                    </xsl:call-template>
                </xsl:for-each>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="CodeRefs">
        <xsl:param name="CodelistAliasRef_parent"/>
        <xsl:param name="CodeID_parent"/>
        <xsl:param name="agencyIDPath"/>

        <xsl:for-each select="structure:CodeRef">
<!--
XXX:
"At a minimum, either a URN value (a valid SDMX Registry URN as specified in teh SDMX Registry Specification) must be supplied, or a ColdelistAliasRef and a CodeID must be specified."
-->
            <xsl:variable name="CodeID">
                <xsl:value-of select="structure:CodeID"/>
            </xsl:variable>

<!--
FIXME:
This is a kind of a hack, works based on tested sample structures. Not guaranteed to work for all URNs. Alternatively, reconsider the data model given URNs
-->
            <xsl:variable name="CodelistAliasRef">
                <xsl:choose>
                    <xsl:when test="structure:URN">
                        <xsl:variable name="structureURN" select="structure:URN"/>

                        <xsl:for-each select="distinct-values(/Structure/HierarchicalCodelists/structure:HierarchicalCodelist/structure:CodelistRef/structure:CodelistID/text())">
                            <xsl:if test="contains($structureURN, .)">
                                <xsl:value-of select="."/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="structure:CodelistAliasRef"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

<!--
XXX:
Dirty?
-->
            <xsl:variable name="agencyIDPath">
                <xsl:choose>
                    <xsl:when test="structure:URN">
                        <xsl:variable name="structureURN" select="structure:URN"/>

                        <xsl:variable name="AgencyID" select="/Structure/HierarchicalCodelists/structure:HierarchicalCodelist/structure:CodelistRef"/>

                        <xsl:for-each select="distinct-values(/Structure/HierarchicalCodelists/structure:HierarchicalCodelist/structure:CodelistRef/structure:CodelistID/text())">
                            <xsl:variable name="CodelistID" select="."/>

                            <xsl:if test="contains($structureURN, $CodelistID)">
                                <xsl:value-of select="distinct-values($AgencyID[structure:CodelistID = $CodelistID]/structure:AgencyID)[1]"/><xsl:text>/</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$agencyIDPath"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

<!--
TODO:
"NodeAliasID allows for an ID to be assigned to the use of the particular code at that specific point in the hierarchy. This value is unique within the hierarchy being created, and is used to map the hierarchy against external structures."
-->

<!--
XXX:
Doublecheck the exact relationship between an hierarchical list and a code list.
Could use dcterms:hasPart or skos:narrower ?
-->
            <skos:narrower>
                <rdf:Description rdf:about="{$code}{$agencyIDPath}{$CodelistAliasRef}/{$CodeID}">
<!--
TODO:
Handle Annotations using skos:note
-->
                    <xsl:if test="$CodelistAliasRef_parent and $CodeID_parent">
                        <skos:broader rdf:resource="{$code}{$agencyIDPath}{$CodelistAliasRef_parent}/{$CodeID_parent}"/>
                    </xsl:if>

                    <xsl:if test="structure:CodeRef">
                        <xsl:call-template name="CodeRefs">
                            <xsl:with-param name="CodelistAliasRef_parent" select="$CodelistAliasRef"/>
                            <xsl:with-param name="CodeID_parent" select="$CodeID"/>
                            <xsl:with-param name="agencyIDPath" select="$agencyIDPath"/>
                        </xsl:call-template>
                    </xsl:if>
                </rdf:Description>
            </skos:narrower>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="DataSets">
        <xsl:for-each select="GenericData/DataSet">
<!--
XXX: KeyfamilyRef may not exist.
-->
            <xsl:variable name="KeyFamilyRef">
                <xsl:choose>
                    <xsl:when test="generic:KeyFamilyRef">
                        <xsl:value-of select="generic:KeyFamilyRef"/>
                    </xsl:when>
                    <xsl:otherwise>
<!--
TODO:
-->
                        <xsl:text>---FIXME---</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
<!--
TODO:
This dataset URI needs to be unique
-->
            <rdf:Description about="{$dataset}{$KeyFamilyRef}">
                <rdf:type rdf:resource="{$qb}DataSet"/>
                <qb:structure rdf:resource="{$dataset}{$KeyFamilyRef}/structure"/>
                <xsl:if test="@datasetID">
                    <skos:notation><xsl:value-of select="@datasetID"/></skos:notation>
                </xsl:if>
<!--
XXX:
Consider getting this value from KeyFamily and adding a suffix e.g., data
                <skos:prefLabel></skos:prefLabel>
-->
            </rdf:Description>

<!--
TODO:
"TextType provides for a set of language-specific alternates to be provided for any human-readable construct in the instance."

This is a one time retrieval but perhaps not necessary for the observations. Revisit.

            <xsl:variable name="PrimaryMeasureTextFormattextType">
                <xsl:value-of select="document($pathToGenericStructure)/Structure/KeyFamilies/structure:KeyFamily[@id = $KeyFamilyRef]/structure:Components/PrimaryMeasure/TextFormat/@textType"/>
            </xsl:variable>
-->


            <xsl:variable name="TimeDimensionConceptRef">
                <xsl:value-of select="document($pathToGenericStructure)/Structure/KeyFamilies/structure:KeyFamily[@id = $KeyFamilyRef]/structure:Components/structure:TimeDimension/@conceptRef"/>
            </xsl:variable>

            <xsl:for-each select="generic:Series">
                <xsl:variable name="SeriesKeyValues">
                    <xsl:for-each select="generic:SeriesKey/generic:Value/@value">
                        <xsl:text>/</xsl:text><xsl:value-of select="normalize-space(.)"/>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:for-each select="generic:Obs">
                    <xsl:variable name="ObsTime">
                        <xsl:value-of select="replace(generic:Time, '\s+', '')"/>
                    </xsl:variable>

                    <xsl:variable name="ObsTimeURI">
                        <xsl:text>/</xsl:text><xsl:value-of select="$ObsTime"/>
                    </xsl:variable>
<!--
TODO:
Create a URI safe function
-->
<!--
TODO:
This dataset URI needs to be unique
-->

                    <rdf:Description about="{$dataset}{$KeyFamilyRef}{$SeriesKeyValues}{$ObsTimeURI}">
                        <xsl:for-each select="../generic:SeriesKey/generic:Value">
                            <xsl:call-template name="ObsProperty">
                                <xsl:with-param name="KeyFamilyRef" select="$KeyFamilyRef"/>
                                <xsl:with-param name="concept" select="@concept"/>
                                <xsl:with-param name="value" select="@value"/>
                            </xsl:call-template>
                        </xsl:for-each>
<!--
TODO:
Revisit datatype or do some smart pattern detection and use a URI if possible
-->
                        <xsl:if test="$ObsTime != '' and $TimeDimensionConceptRef != ''">
                            <xsl:element name="property:{$TimeDimensionConceptRef}">
                                <xsl:value-of select="$ObsTime"/>
                            </xsl:element>
                        </xsl:if>

                        <xsl:for-each select="generic:ObsValue">
                            <property:OBS_VALUE>
                                <xsl:call-template name="datatype-xsd-double"/>
                                <xsl:value-of select="@value"/>
                            </property:OBS_VALUE>
                        </xsl:for-each>

                        <xsl:for-each select="generic:Attributes/generic:Value">
                            <xsl:call-template name="ObsProperty">
                                <xsl:with-param name="KeyFamilyRef" select="$KeyFamilyRef"/>
                                <xsl:with-param name="concept" select="@concept"/>
                                <xsl:with-param name="value" select="@value"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </rdf:Description>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="ObsProperty">
        <xsl:param name="KeyFamilyRef"/>
        <xsl:param name="concept"/>
        <xsl:param name="value"/>

        <xsl:element name="property:{$concept}">
            <xsl:attribute name="rdf:resource">
                <xsl:variable name="codelist">
                    <xsl:value-of select="document($pathToGenericStructure)/Structure/KeyFamilies/structure:KeyFamily[@id = $KeyFamilyRef]/structure:Components/*[@conceptRef = $concept]/@codelist"/>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="$codelist != ''">
                        <xsl:value-of select="$code"/><xsl:value-of select="$codelist"/><xsl:text>/</xsl:text><xsl:value-of select="$value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$concept"/><xsl:value-of select="$value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
