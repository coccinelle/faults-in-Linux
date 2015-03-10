#!/bin/bash

. ../../common.sh ../..

ORIG=../../tools/count_lines
PPDIR=../populate-funcs
BIN=count_lines

rm -Rf tmp
mkdir tmp
#cat $ORIG/Makefile | grep -v 'main_ages.ml' | grep -v 'middle_churn.ml' > tmp/Makefile
#cp $ORIG/Makefile.config tmp
#cp $ORIG/main.ml tmp
#cp $ORIG/main_ages.ml tmp
#cp $ORIG/cocci.ml tmp
#cp $ORIG/flag_cocci.* tmp
#cp $ORIG/get_maintainer.pl tmp
#cp $ORIG/standard.h tmp

cd tmp
ln -s ../$ORIG/$BIN .
#make 1>&2
#make 1>&2

mkdir -p $PPDIR

gengen() {
		echo "#!/bin/bash"
		echo
		echo "./$BIN $LINUXES/\$1 | while read cur; do"
		echo "    FN=\$(echo \$cur | cut -d' ' -f4)"
 		echo "		if [ -z \"\$(echo \$cur | grep function | grep start | grep finish)\" ]; then"
 		echo "				if [ -z \"\$(echo \$cur | grep 'THE REST')\" ]; then"
 		echo "						echo \"update files set file_size=\$(echo \$cur | cut -d' ' -f6)\""
 		echo "						echo \"  where version_name='\$1' and file_name='\$FN';\""
 		echo "				fi"
 		echo "		else"
 		echo "				echo \"insert into functions (file_id, start, finish, function_name)\""
 		echo "				echo \"  values (get_file('\$1', '\$FN'), \$(echo \$cur | cut -d' ' -f8), \$(echo \$cur | cut -d' ' -f10), '\$(echo \$cur | cut -d' ' -f6)');\""
 		echo "		fi"
 		echo "  done"
}

gengen > gen.sh
chmod a+x gen.sh

genmakefile() {
		echo ".PHONY: all"
		echo
		echo -ne "all:"
		while read line; do
 				V=$(echo $line | cut -d' ' -f1)
 				echo -ne " $PPDIR/populate-$V.sql"
		done < ../$VERSION_FILE

		echo

		while read line; do
				echo
 				V=$(echo $line | cut -d' ' -f1)
				echo "$PPDIR/populate-$V.sql: "
				echo -e "\t./gen.sh $V > \$@ 2>$PPDIR/populate-$V.err"
		done < ../$VERSION_FILE
}

genmakefile > Makefile.2

make -j -f Makefile.2

cd ..
#rm -Rf tmp
