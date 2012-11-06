#!/bin/bash

saxonb-xslt -s ../samples/WB.KeyFamily.xml -xsl generic.xsl > ../samples/WB.KeyFamily.rdf
#saxonb-xslt -s ../samples/OECD.HEALTH_STAT.xml -xsl generic.xsl > ../samples/OECD.HEALTH_STAT.rdf
#saxonb-xslt -s ../samples/IMF.BOPDSD.xml -xsl generic.xsl > ../samples/IMF.BOPDSD.rdf
#saxonb-xslt -s ../samples/SDMX.StructureSample.xml -xsl generic.xsl > ../samples/SDMX.StructureSample.rdf
#saxonb-xslt -s ../samples/Eurostat.tps00001.dsd.xml -xsl generic.xsl > ../samples/Eurostat.tps00001.dsd.rdf
#saxonb-xslt -s ../samples/FAO.TRADE_DATASTRUCTURE.xml -xsl generic.xsl > ../samples/FAO.TRADE_DATASTRUCTURE.rdf
#saxonb-xslt -s ../samples/FAO.HCL_AREA_SUB_AREA.xml -xsl generic.xsl > ../samples/FAO.HCL_AREA_SUB_AREA.rdf
#saxonb-xslt -s ../samples/FAO.CL_FAO_MAJOR_AREA.xml -xsl generic.xsl > ../samples/FAO.CL_FAO_MAJOR_AREA.rdf
saxonb-xslt -s ../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml -xsl generic.xsl > ../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.rdf
saxonb-xslt -s ../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443131267.xml -xsl generic.xsl pathToGenericStructure=../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml > ../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443131267.rdf
#saxonb-xslt -s ../samples/ECB.KeyFamily.xml -xsl generic.xsl > ../samples/ECB.KeyFamily.rdf

saxonb-xslt -s ../samples/WB.sp.pop.totl.xml -xsl generic.xsl pathToGenericStructure=../samples/WB.KeyFamily.xml > ../samples/WB.sp.pop.totl.rdf
#saxonb-xslt -s ../samples/OECD.HEALTH_STAT.data.xml -xsl generic.xsl > ../samples/OECD.HEALTH_STAT.data.rdf
#saxonb-xslt -s ../samples/SDMX.GenericSample.xml -xsl generic.xsl > ../samples/SDMX.GenericSample.rdf
#saxonb-xslt -s ../samples/FAO.CAPTURE_DATASTRUCTURE.xml -xsl generic.xsl pathToGenericStructure=../samples/FAO.CAPTURE_DATASTRUCTURE.xml > ../samples/FAO.CAPTURE_DATASTRUCTURE.rdf
#saxonb-xslt -s ../samples/FAO.CAPTURE.xml -xsl generic.xsl pathToGenericStructure=../samples/FAO.CAPTURE_DATASTRUCTURE.xml > ../samples/FAO.CAPTURE.rdf
