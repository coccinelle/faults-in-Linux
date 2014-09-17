#!/bin/bash

#
# To be invoked by   find results/ -type f -name *.org -exec ./ren.sh \{} \;
#

FILE=$1

FILENAME=`basename $FILE`
DIR=`dirname $FILE`
NEW=`echo $FILENAME | sed 's/Linux-2.6_/Linux_/'`

mv $FILE $DIR/$NEW
