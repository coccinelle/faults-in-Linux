#!/bin/bash

. ../../common.sh

if [ -d $LINUXES/linux-next/.git ];then
    GIT=$LINUXES/linux-next/.git
    DB=
else
    GIT=~/Documents/build/linux/.git
    DB="-h localhost -p 5432"
fi

VLIST="SELECT version_name FROM versions WHERE release_date >= '2005-06-17';"

> /tmp/version_commit_id

for versname in `echo "$VLIST" | psql $DBNAME $DB -t`; do

    vers=`echo $versname | cut -f2 -d'-'`
    hash=`git --git-dir $GIT log -1 --format="%H" v$vers`

    echo "UPDATE versions SET commit_id = '$hash' WHERE version_name = '$versname';" \
	>> /tmp/version_commit_id

done

cat /tmp/version_commit_id | psql $DBNAME $DB

rm /tmp/version_commit_id
