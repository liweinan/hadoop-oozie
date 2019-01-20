#!/usr/bin/env bash
set -x

oozied.sh start
oozie admin -oozie http://localhost:11000/oozie -status
./wait-for-it.sh hadoop:8020 -- oozie-setup.sh sharelib create -fs hdfs://hadoop:8020

/bin/bash
