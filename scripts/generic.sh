#!/bin/bash

rapper -g config.ttl -o rdfxml-abbrev > config.rdf

#ls -1 ../samples/*.xml | sed 's/\.xml//' | while read i; do saxonb-xslt -s "$i".xml -xsl /var/www/sdmx-to-qb/scripts/generic.xsl > "$i".rdf; echo "Created $i.rdf"; done

saxonb-xslt -s ../samples/WB.KeyFamily.xml -xsl generic.xsl xmlDocument=../samples/WB.KeyFamily.xml > ../samples/WB.KeyFamily.rdf
saxonb-xslt -s ../samples/OECD.HEALTH_STAT.xml -xsl generic.xsl xmlDocument=../samples/OECD.HEALTH_STAT.xml > ../samples/OECD.HEALTH_STAT.rdf
saxonb-xslt -s ../samples/IMF.BOPDSD.xml -xsl generic.xsl xmlDocument=../samples/IMF.BOPDSD.xml > ../samples/IMF.BOPDSD.rdf
saxonb-xslt -s ../samples/SDMX.StructureSample.xml -xsl generic.xsl xmlDocument=../samples/SDMX.StructureSample.xml > ../samples/SDMX.StructureSample.rdf
saxonb-xslt -s ../samples/Eurostat.tps00001.dsd.xml -xsl generic.xsl xmlDocument=../samples/Eurostat.tps00001.dsd.xml > ../samples/Eurostat.tps00001.dsd.rdf
saxonb-xslt -s ../samples/FAO.TRADE_DATASTRUCTURE.xml -xsl generic.xsl xmlDocument=../samples/FAO.TRADE_DATASTRUCTURE.xml > ../samples/FAO.TRADE_DATASTRUCTURE.rdf
saxonb-xslt -s ../samples/FAO.HCL_AREA_SUB_AREA.xml -xsl generic.xsl xmlDocument=../samples/FAO.HCL_AREA_SUB_AREA.xml > ../samples/FAO.HCL_AREA_SUB_AREA.rdf
saxonb-xslt -s ../samples/FAO.CL_FAO_MAJOR_AREA.xml -xsl generic.xsl xmlDocument=../samples/FAO.CL_FAO_MAJOR_AREA.xml > ../samples/FAO.CL_FAO_MAJOR_AREA.rdf
saxonb-xslt -s ../samples/HDI.DSD.HDR.xml -xsl generic.xsl xmlDocument=../samples/HDI.DSD.HDR.xml > ../samples/HDI.DSD.HDR.rdf
saxonb-xslt -s ../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml -xsl generic.xsl xmlDocument=../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml > ../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.rdf
saxonb-xslt -t -tree:linked -s ../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443131267.xml -xsl generic.xsl xmlDocument=../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443131267.xml pathToGenericStructure=../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443106306.xml > ../samples/BIS.WEBSTATS_CIBL_UR_DATAFLOW-1351443131267.rdf
saxonb-xslt -s ../samples/ECB.KeyFamily.xml -xsl generic.xsl xmlDocument=../samples/ECB.KeyFamily.xml > ../samples/ECB.KeyFamily.rdf

saxonb-xslt -s ../samples/WB.sp.pop.totl.xml -xsl generic.xsl xmlDocument=../samples/WB.sp.pop.totl.xml pathToGenericStructure=../samples/WB.KeyFamily.xml > ../samples/WB.sp.pop.totl.rdf
saxonb-xslt -s ../samples/OECD.HEALTH_STAT.data.xml -xsl generic.xsl xmlDocument=../samples/OECD.HEALTH_STAT.data.xml pathToGenericStructure=../samples/OECD.HEALTH_STAT.xml > ../samples/OECD.HEALTH_STAT.data.rdf
saxonb-xslt -s ../samples/SDMX.GenericSample.xml -xsl generic.xsl xmlDocument=../samples/SDMX.GenericSample.xml pathToGenericStructure=../samples/SDMX.StructureSample.xml > ../samples/SDMX.GenericSample.rdf
saxonb-xslt -s ../samples/FAO.CAPTURE_DATASTRUCTURE.xml -xsl generic.xsl xmlDocument=../samples/FAO.CAPTURE_DATASTRUCTURE.xml > ../samples/FAO.CAPTURE_DATASTRUCTURE.rdf
saxonb-xslt -s ../samples/FAO.CAPTURE.xml -xsl generic.xsl xmlDocument=../samples/FAO.CAPTURE.xml pathToGenericStructure=../samples/FAO.CAPTURE_DATASTRUCTURE.xml > ../samples/FAO.CAPTURE.rdf
saxonb-xslt -s ../samples/Eurostat.tps00001.sdmx.xml -xsl generic.xsl xmlDocument=../samples/Eurostat.tps00001.sdmx.xml pathToGenericStructure=../samples/Eurostat.tps00001.dsd.xml > ../samples/Eurostat.tps00001.sdmx.rdf

saxonb-xslt -t -tree:linked -s ../samples/CH1_RN+HCL_HGDE_HIST+1.0.xml -xsl generic.xsl xmlDocument=../samples/CH1_RN+HCL_HGDE_HIST+1.0.xml > ../samples/CH1_RN+HCL_HGDE_HIST+1.0.rdf

