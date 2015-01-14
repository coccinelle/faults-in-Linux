#!/bin/bash

. ../../common.sh

ALL=1

while read RELEASE; do
	if [ -z "`echo $RELEASE | grep -v '#'`" ]; then
		continue
	fi

	ID=$(echo $RELEASE | cut -d' ' -f1)
	NAME=$(echo $RELEASE | cut -d' ' -f2)
	DATE=$(echo $RELEASE | cut -d' ' -f3)
	COMMITID=$(echo $RELEASE | cut -d' ' -f4)

	VERSION=$(echo $NAME | cut -d'-' -f2)

	MAIN=$(echo $VERSION | cut -d'.' -f1)
	MAJOR=$(echo $VERSION | cut -d'.' -f2)
	MINOR=$(echo $VERSION | cut -d'.' -f3)

	if [ -z "$COMMITID" ]; then
	        if [ -z "$MINOR" ]; then
		    echo "insert into versions (version_name, main, major, release_date)"
		    echo "	values ('$ID', $MAIN, $MAJOR, timestamp '$DATE');"
		else
        	    echo "insert into versions (version_name, main, major, minor, release_date)"
		    echo "	values ('$ID', $MAIN, $MAJOR, $MINOR, timestamp '$DATE');"
	        fi
	else
	        if [ -z "$MINOR" ]; then
		    echo "insert into versions (version_name, main, major, release_date, commit_id)"
		    echo "	values ('$ID', $MAIN, $MAJOR, timestamp '$DATE', '$COMMITID');"
		else
        	    echo "insert into versions (version_name, main, major, minor, release_date, commit_id)"
		    echo "	values ('$ID', $MAIN, $MAJOR, $MINOR, timestamp '$DATE', '$COMMITID');"
	        fi
	fi

	if [ -n "$ALL" ]; then
	    FULL=$LINUXES/$NAME
	    LEN=$[${#FULL} + 1]
	    for FN in $(find $LINUXES/$NAME -iname "*\.[ch]"); do
		ALLDIR=$(dirname $FN)
		DIR=${ALLDIR:$LEN}"/"
		FILE=$(basename $FN)
		
		echo "insert into files (file_name, version_name) values (add_file_name('$DIR$FILE'), '$ID');"
	    done
	    echo
	fi

done < $VERSION_FILE
