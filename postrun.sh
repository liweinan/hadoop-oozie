#!/usr/bin/env bash
set -x

sed -i '$ d' /opt/oozie-4.2.0/conf/oozie-site.xml
cat /tmp/oozie-site.xml.fragment >> /opt/oozie-4.2.0/conf/oozie-site.xml
echo '</configuration>' >> /opt/oozie-4.2.0/conf/oozie-site.xml

#oozied.sh start
#oozie admin -oozie http://localhost:11000/oozie -status
#./wait-for-it.sh -t 0 hadoop:54321 -- oozie-setup.sh sharelib create -fs hdfs://hadoop:9000
# needs restart
#oozied.sh stop
#oozied.sh start
#oozie admin -shareliblist

tail -f /dev/null
