#!/bin/bash

#
# First copy from ACM TOCS results
#
# cd ~/atocs/experiments/mainline/results/linuxes
#
# Copy to here from there
#
# find -mindepth 2 -name "Linux-2.6_null_ref6.orig.org" \
# 	-exec cp \{} /home/npalix/faults-in-linux.exp/results/linuxes/\{} \;
#
# To be invoked by   find results/ -type f -name *.org -exec ./ren.sh \{} \;
#

FILE=$1

FILENAME=`basename $FILE`
DIR=`dirname $FILE`
NEW=`echo $FILENAME | sed 's/Linux-2.6_/Linux_/'`

mv $FILE $DIR/$NEW
