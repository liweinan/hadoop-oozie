#!/usr/bin/env bash
set -x

oozied.sh start
oozie admin -oozie http://localhost:11000/oozie -status
./wait-for-it.sh hadoop:9000 -- oozie-setup.sh sharelib create -fs hdfs://hadoop:9000

/bin/bash
