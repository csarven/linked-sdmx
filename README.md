# SDMX-ML to RDF/XML

Brief overview of the project is here. If you want to use it or look under the hood for additional information, give the [wiki](https://github.com/csarven/linked-sdmx/wiki) page a go.

## What is this?

XSLT 2.0 templates and scripts to transform Generic [SDMX 2.0](http://sdmx.org/?page_id=16#package) data and metadata to RDF/XML using the [RDF Data Cube](http://www.w3.org/TR/vocab-data-cube/) and related vocabularies for statistical Linked Data. Its purpose is:

* To automagically transform SDMX-ML data and metadata into RDF/XML as semantically and complete as possible.
* To support SDMX publishers to also publish their data using RDF.
* To improve access and discovery of statistical cross-domain data.

## What can it do?
* Transforms SDMX KeyFamilies, ConceptSchemes and Concepts, CodeLists and Codes, Hierarchical CodeLists, DataSets.
* Configurability for SDMX publisher's needs.
* Reuse of CodeLists and Codes from external agencies.
* A way to interlink AnnotationTypes.
* Provides basic provenance data using PROV-O.

## What is inside?

It comes with scripts and sample data.

### Scripts
* XSLT 2.0 templates to transform Generic SDMX-ML data and metadata. It includes the main XSL template for generic SDMX-ML, an XSL for common templates and functions, and an RDF/XML configuration file to set preferences like base URIs, delimiters in URIs, how to mapping annotation types.
* Bash script that transforms sample data using saxonb-xslt.

### Samples
Sample SDMX Message and Structure [data/](https://github.com/csarven/linked-sdmx/tree/master/data) retrieved from these organizations: <a href="http://www.bis.org/" title="Bank for International Statements">BIS</a>, <a href="http://www.oecd.org/" title="Organisation for Economic Co-operation and Development">OECD</a>, <a href="http://www.un.org/" title="United Nations">UN</a>, <a href="http:/www.ecb.int/" title="European Central Bank">ECB</a>, <a href="http://worldbank.org/" title="World Bank">WB</a>, <a href="http://imf.org/" title="International Monetary Fund">IMF</a>, <a href="http://fao.org/" title="Food and Agriculture Organization of the United Nations">FAO</a>, <a href="http://epp.eurostat.ec.europa.eu/" title="Eurostat">EUROSTAT</a>, <a href="http://www.bfs.admin.ch/" title="Swiss Federal Statistical Office">BFS</a>.

### Requirements
An XSLT 2.0 processor to transform, and some configuring using the provided config.rdf file.

## How to contribute
* See [open GitHub issues](https://github.com/csarven/linked-sdmx/issues?state=open) if you want to hack, or create issues if you encounter bugs, or enhancements within the scope of this project. There are also some questions that would be nice to get answers to.
* Please send pull requests or help improve documentation.
* Reach out to organizations that publish data using the SDMX-ML to collaborate on this effort.
