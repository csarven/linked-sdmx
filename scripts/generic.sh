#!/bin/bash

rapper -g config.ttl -o rdfxml-abbrev > config.rdf
rapper -g agencies.ttl -o rdfxml-abbrev > agencies.rdf

#saxonb-xslt -t -tree:linked -s ../data/WB.KeyFamily.xml -xsl generic.xsl xmlDocument=../data/WB.KeyFamily.xml pathToGenericStructure=../data/WB.KeyFamily.xml > ../data/WB.KeyFamily.rdf
#saxonb-xslt -t -tree:linked -s ../data/WB.sp.pop.totl.xml -xsl generic.xsl xmlDocument=../data/WB.sp.pop.totl.xml pathToGenericStructure=../data/WB.KeyFamily.xml > ../data/WB.sp.pop.totl.rdf

#saxonb-xslt -t -tree:linked -s ../data/Eurostat.tps00001.dsd.xml -xsl generic.xsl xmlDocument=../data/Eurostat.tps00001.dsd.xml pathToGenericStructure=../data/Eurostat.tps00001.dsd.xml > ../data/Eurostat.tps00001.dsd.rdf
#saxonb-xslt -t -tree:linked -s ../data/Eurostat.tps00001.sdmx.xml -xsl generic.xsl xmlDocument=../data/Eurostat.tps00001.sdmx.xml pathToGenericStructure=../data/Eurostat.tps00001.dsd.xml > ../data/Eurostat.tps00001.sdmx.rdf

#saxonb-xslt -t -tree:linked -s ../data/HDI.DSD.HDR.xml -xsl generic.xsl xmlDocument=../data/HDI.DSD.HDR.xml pathToGenericStructure=../data/HDI.DSD.HDR.xml > ../data/HDI.DSD.HDR.rdf

#saxonb-xslt -t -tree:linked -s ../data/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml -xsl generic.xsl xmlDocument=../data/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml pathToGenericStructure=../data/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml > ../data/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.rdf
#saxonb-xslt -t -tree:linked -s ../data/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443131267.xml -xsl generic.xsl xmlDocument=../data/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443131267.xml pathToGenericStructure=../data/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml > ../data/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443131267.rdf

#saxonb-xslt -t -tree:linked -s ../data/OECD.HEALTH_STAT.xml -xsl generic.xsl xmlDocument=../data/OECD.HEALTH_STAT.xml pathToGenericStructure=../data/OECD.HEALTH_STAT.xml > ../data/OECD.HEALTH_STAT.rdf
#saxonb-xslt -t -tree:linked -s ../data/OECD.HEALTH_STAT.data.xml -xsl generic.xsl xmlDocument=../data/OECD.HEALTH_STAT.data.xml pathToGenericStructure=../data/OECD.HEALTH_STAT.xml > ../data/OECD.HEALTH_STAT.data.rdf

#saxonb-xslt -t -tree:linked -s ../data/FAO.CAPTURE_DATASTRUCTURE.xml -xsl generic.xsl xmlDocument=../data/FAO.CAPTURE_DATASTRUCTURE.xml pathToGenericStructure=../data/FAO.CAPTURE_DATASTRUCTURE.xml > ../data/FAO.CAPTURE_DATASTRUCTURE.rdf
#saxonb-xslt -t -tree:linked -s ../data/FAO.CAPTURE.xml -xsl generic.xsl xmlDocument=../data/FAO.CAPTURE.xml pathToGenericStructure=../data/FAO.CAPTURE_DATASTRUCTURE.xml > ../data/FAO.CAPTURE.rdf

#saxonb-xslt -t -tree:linked -s ../data/FAO.TRADE_DATASTRUCTURE.xml -xsl generic.xsl xmlDocument=../data/FAO.TRADE_DATASTRUCTURE.xml pathToGenericStructure=../data/FAO.TRADE_DATASTRUCTURE.xml > ../data/FAO.TRADE_DATASTRUCTURE.rdf
#saxonb-xslt -t -tree:linked -s ../data/FAO.HCL_AREA_SUB_AREA.xml -xsl generic.xsl xmlDocument=../data/FAO.HCL_AREA_SUB_AREA.xml pathToGenericStructure=../data/FAO.HCL_AREA_SUB_AREA.xml  > ../data/FAO.HCL_AREA_SUB_AREA.rdf
#saxonb-xslt -t -tree:linked -s ../data/FAO.CL_FAO_MAJOR_AREA.xml -xsl generic.xsl xmlDocument=../data/FAO.CL_FAO_MAJOR_AREA.xml pathToGenericStructure=../data/FAO.CL_FAO_MAJOR_AREA.xml > ../data/FAO.CL_FAO_MAJOR_AREA.rdf

#saxonb-xslt -t -tree:linked -s ../data/IMF.BOPDSD.xml -xsl generic.xsl xmlDocument=../data/IMF.BOPDSD.xml pathToGenericStructure=../data/IMF.BOPDSD.xml > ../data/IMF.BOPDSD.rdf
#saxonb-xslt -t -tree:linked -s ../data/IMF.BOP.Advanced_Economies.xml -xsl generic.xsl xmlDocument=../data/IMF.BOP.Advanced_Economies.xml pathToGenericStructure=../data/IMF.BOPDSD.xml > ../data/IMF.BOP.Advanced_Economies.rdf

#saxonb-xslt -t -tree:linked -s ../data/ECB.KeyFamily.xml -xsl generic.xsl xmlDocument=../data/ECB.KeyFamily.xml pathToGenericStructure=../data/ECB.KeyFamily.xml > ../data/ECB.KeyFamily.rdf

#saxonb-xslt -t -tree:linked -s ../data/SDMX.StructureSample.xml -xsl generic.xsl xmlDocument=../data/SDMX.StructureSample.xml pathToGenericStructure=../data/SDMX.StructureSample.xml > ../data/SDMX.StructureSample.rdf
#saxonb-xslt -t -tree:linked -s ../data/SDMX.GenericSample.xml -xsl generic.xsl xmlDocument=../data/SDMX.GenericSample.xml pathToGenericStructure=../data/SDMX.StructureSample.xml > ../data/SDMX.GenericSample.rdf

#saxonb-xslt -t -tree:linked -s ../data/BFS.CH1_RN+HCL_HGDE_HIST+1.0.xml -xsl generic.xsl xmlDocument=../data/BFS.CH1_RN+HCL_HGDE_HIST+1.0.xml pathToGenericStructure=../data/BFS.CH1_RN+HCL_HGDE_HIST+1.0.xml > ../data/BFS.CH1_RN+HCL_HGDE_HIST+1.0.rdf

