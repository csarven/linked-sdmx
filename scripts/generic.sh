#!/bin/bash

saxonb-xslt -s ../samples/WB.KeyFamily.xml -xsl generic.xsl > ../samples/WB.KeyFamily.rdf
saxonb-xslt -s ../samples/OECD.HEALTH_STAT.xml -xsl generic.xsl > ../samples/OECD.HEALTH_STAT.rdf
saxonb-xslt -s ../samples/IMF.BOPDSD.xml -xsl generic.xsl > ../samples/IMF.BOPDSD.rdf
saxonb-xslt -s ../samples/SDMX.StructureSample.xml -xsl generic.xsl > ../samples/SDMX.StructureSample.rdf
saxonb-xslt -s ../samples/Eurostat.tps00001.dsd.xml -xsl generic.xsl > ../samples/Eurostat.tps00001.dsd.rdf
saxonb-xslt -s ../samples/FAO.TRADE_DATASTRUCTURE.xml -xsl generic.xsl > ../samples/FAO.TRADE_DATASTRUCTURE.rdf
