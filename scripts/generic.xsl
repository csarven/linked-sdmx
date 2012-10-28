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

    xpath-default-namespace="http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message"
    exclude-result-prefixes="xsl fn structure message"
    >

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="lang"/>
    <xsl:param name="base"/>
<!--
TODO:
* Consider offering an option to use human readable URIs e.g., world-development-indicators (from Header::Name) instead of WDI
* Decide whether to leave the string cases as is or change e.g., lowercased, separated by dash
-->

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


    <xsl:template match="/">
<!--<xsl:message>-->
<!--<xsl:text>base: </xsl:text><xsl:value-of select="$base"/>-->
<!--<xsl:text>baseuri: </xsl:text><xsl:value-of select="$baseuri"/>-->
<!--</xsl:message>-->

        <rdf:RDF>
            <xsl:call-template name="KeyFamily"/>

            <xsl:call-template name="Concepts"/>

            <xsl:call-template name="CodeLists"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="KeyFamily">
        <xsl:for-each select="Structure/KeyFamilies/structure:KeyFamily">
<!--
TODO:
Merge these. Change it to xsl:function
-->
            <xsl:variable name="id">
                <xsl:call-template name="getAttributeValue"><xsl:with-param name="attributeName" select="@id"/></xsl:call-template>
            </xsl:variable>
            <xsl:variable name="agencyID">
                <xsl:call-template name="getAttributeValue"><xsl:with-param name="attributeName" select="@agencyID"/></xsl:call-template>
            </xsl:variable>

            <rdf:Description rdf:about="{$baseuri}dataset/{$id}/structure">
                <rdf:type rdf:resource="http://purl.org/linked-data/sdmx#DataStructureDefinition"/>
<!-- XXX:               <rdf:type rdf:resource="{$qb}DataStructureDefinition"/>-->

<!-- TODO:
* Review these properties. Some are close enough to existing SDMX, some I made them up - they should be added to sdmx* vocabs
* Consider creating sdmx-concept URIs for dsi/mAgency ...?
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

                <xsl:call-template name="structureComponents"/>
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

        <xsl:for-each select="structure:Components/*">
            <qb:component>
                <qb:ComponentSpecification>
                    <xsl:choose>
                        <xsl:when test="local-name() = 'Dimension' or local-name() = 'TimeDimension'">
                            <qb:dimension>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="$property"/><xsl:value-of select="@conceptRef"/>
                                </xsl:attribute>
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
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="$property"/><xsl:value-of select="@conceptRef"/>
                                </xsl:attribute>
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
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="$property"/><xsl:value-of select="@conceptRef"/>
                                </xsl:attribute>
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
            <xsl:call-template name="getAttributeValue"><xsl:with-param name="attributeName" select="@id"/></xsl:call-template>
        </xsl:variable>
        <xsl:variable name="agencyID">
            <xsl:call-template name="getAttributeValue"><xsl:with-param name="attributeName" select="@agencyID"/></xsl:call-template>
        </xsl:variable>

        <rdf:Description rdf:about="{$concept}{$id}">
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
            <xsl:call-template name="getAttributeValue"><xsl:with-param name="attributeName" select="@id"/></xsl:call-template>
        </xsl:variable>
        <xsl:variable name="agencyID">
            <xsl:call-template name="getAttributeValue"><xsl:with-param name="attributeName" select="@agencyID"/></xsl:call-template>
        </xsl:variable>

<!--
TODO:
Consider whether to include agencyID here because.. what happens if a KeyFamily mixes agencyIDs?
-->
        <rdf:Description rdf:about="{$concept}{$id}">
<!--
XXX:
Maybe this should be excluded since sdmx:Concept is a rdfs:subClassOf skos:Concept
-->
            <rdf:type rdf:resource="{$sdmx}Concept"/>
            <rdf:type rdf:resource="{$skos}Concept"/>

            <xsl:if test="$ConceptSchemeID">
                <skos:topConceptOf rdf:resource="{$concept}{$ConceptSchemeID}"/>
                <skos:inScheme rdf:resource="{$concept}{$ConceptSchemeID}"/>
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
                <xsl:call-template name="getAttributeValue"><xsl:with-param name="attributeName" select="@id"/></xsl:call-template>
            </xsl:variable>
            <xsl:variable name="agencyID">
                <xsl:call-template name="getAttributeValue"><xsl:with-param name="attributeName" select="@agencyID"/></xsl:call-template>
            </xsl:variable>

            <rdf:Description rdf:about="{$code}{$id}">
                <rdf:type rdf:resource="{$sdmx}CodeList"/>

                <xsl:if test="@uri">
                    <rdfs:isDefinedBy rdf:resource="{@uri}"/>
                </xsl:if>

                <skos:notation><xsl:value-of select="$id"/></skos:notation>
                <xsl:apply-templates select="structure:Name"/>

                <xsl:for-each select="structure:Code">
                    <skos:hasTopConcept>
                        <rdf:Description rdf:about="{$code}{$id}/{@value}">
<!--
XXX:
Hello redundancy!
-->
                            <rdf:type rdf:resource="{$sdmx}Concept"/>
                            <rdf:type rdf:resource="{$skos}Concept"/>
                            <rdf:type rdf:resource="{$code}{$id}"/>
                            <skos:topConceptOf rdf:resource="{$code}{$id}"/>
                            <skos:inScheme rdf:resource="{$code}{$id}"/>

                            <xsl:if test="@uri">
                                <rdfs:isDefinedBy rdf:resource="{@uri}"/>
                            </xsl:if>

                            <skos:notation><xsl:value-of select="@value"/></skos:notation>
                            <xsl:apply-templates select="structure:Description"/>
                        </rdf:Description>
                    </skos:hasTopConcept>
                </xsl:for-each>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
