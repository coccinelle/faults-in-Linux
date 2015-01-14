#!/bin/sh

RELPATH=$1

HOST=`hostname`
LOCALCONF=$RELPATH/common.local.sh

if [ -z "$DBNAME" ]; then
		DBNAME=faults_in_Linux
fi

if [ -z "$LINUXES" ]; then
		LINUXES=/fast_scratch/linuxes
fi

if [ -z "$VERSION_FILE" ]; then
		VERSION_FILE=versions.txt
fi

if [ -f $LOCALCONF ] ; then
	. $LOCALCONF 
fi

export PGDATABASE=$DBNAME
export PGHOST=$HOST
export DB="-h $PGHOST $PGDATABASE"

