#!/bin/sh

. ../../common.sh ../..

cat > /tmp/NOTES-in-collect <<EOF
#Linux-2.4_bad_kfree_notes.orig.org.gz
#Linux-2.4_bad_lock_notes.orig.org.gz
#Linux-2.6_bad_kfree_notes.orig.org.gz
#Linux-2.6_bad_lock_notes.orig.org.gz
#Mini-osdi_bad_lock1_notes.orig.org.gz
#Mini-osdi_bad_lock2_notes.orig.org.gz
#Mini-osdi_bad_null2_notes.orig.org.gz
#Linux-2.6_bad_null3_notes.orig.org.gz
EOF
chmod a+w /tmp/NOTES-in-collect

COLLDIR=../../collect_lists/run_kfree_tests/results/linuxes

CWD=`pwd`
LOGFILE=$CWD/`basename $0 .sh`.log

if [ $# -ne 1 ] ; then
        echo "usage: `basename $0` [ reset | init ]"
	exit 1
fi

if [ "$1" = "reset" ] ; then
	echo "SELECT setval('notes_note_id_seq', 1, false);" | psql $DBNAME -e -q -o /dev/null
	echo "TRUNCATE notes CASCADE;" | psql $DBNAME -e -q -o /dev/null
fi

if [ "$1" = "init" ] ; then

> $LOGFILE
#> populate-notes.sql

for f in `grep -v "^#" /tmp/NOTES-in-collect`; do
    echo "Processing $f" > /dev/stderr
    echo "*** Processing $f ***" >> $LOGFILE
    EXPANDED=`basename $f .gz`

    if [ ! -f $COLLDIR/$EXPANDED ] ; then
	echo -n "Expanding in $EXPANDED. " > /dev/stderr
	if [ "$f" = "Linux-2.4_bad_kfree_notes.orig.org.gz" ]; then
		zcat $COLLDIR/$f | grep "2\.4\.1" > $COLLDIR/$EXPANDED
	elif [ "$f" = "Linux-2.4_bad_lock_notes.orig.org.gz" ]; then
		zcat $COLLDIR/$f | grep "2\.4\.1" > $COLLDIR/$EXPANDED
	else
		zcat $COLLDIR/$f > $COLLDIR/$EXPANDED
	fi
	echo "Done." > /dev/stderr;
    fi
    org2sql.opt $COLLDIR/$EXPANDED --notes --prefix /var/linuxes/ \
    | psql $DBNAME -e -q 2>&1 | tee >> $LOGFILE
#     >> populate-notes.sql
done

fi

