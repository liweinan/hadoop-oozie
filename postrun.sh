#!/usr/bin/env bash
set -x

oozied.sh start
oozie admin -oozie http://localhost:11000/oozie -status

/bin/bash
