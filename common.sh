#!/bin/sh

HOST=`hostname`

if [ -z "$DBNAME" ]; then
		DBNAME=faults_in_Linux
fi

if [ -z "$LINUXES" ]; then
		LINUXES=/fast_scratch/linuxes
fi

if [ -z "$VERSION_FILE" ]; then
		VERSION_FILE=versions.txt
fi

export PGDATABASE=$DBNAME

if [ "$HOST" = "xxxx" ] ; then
export PGHOST=localhost
DB="-h $PGHOST $PGDATABASE"
else
DB="$PGDATABASE"
fi

