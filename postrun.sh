#!/usr/bin/env bash
set -x

sed -i '$ d' /opt/oozie-4.2.0/conf/oozie-site.xml
cat /tmp/libpath.xml >> /opt/oozie-4.2.0/conf/oozie-site.xml
echo '</configuration>' >> /opt/oozie-4.2.0/conf/oozie-site.xml

oozied.sh start
oozie admin -oozie http://localhost:11000/oozie -status
./wait-for-it.sh hadoop:54321 -- oozie-setup.sh sharelib create -fs hdfs://hadoop:9000

oozie admin -shareliblist

tail -f /dev/null
