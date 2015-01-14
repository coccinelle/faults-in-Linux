
DBNAME=faults_in_Linux

.PHONY: all rebuild-all reinit-db populate-files populate-funcs clean cleanall distclean
.SECONDARY:
.SUFFIXES:

all:
	@echo "usage:"
	@echo "  make rebuild-all    DBNAME=database_name: all"
	@echo "  make reinit-db      DBNAME=database_name: destroy the data base and rebuild it"
	@echo "  make populate-files DBNAME=database_name: insert all the files and versions in the data base"
	@echo "  make populate-funcs DBNAME=database_name: insert all the functions in the data base"
	@echo
	@echo "  by default, DBNAME=$(DBNAME)"

rebuild-all:populate-files populate-funcs

reinit-db:
#	-echo "drop database $(DBNAME)" | psql postgres > /dev/null
#	echo "create database $(DBNAME)" | psql postgres > /dev/null
# 	psql $(DBNAME) -f build-tables.sql > /dev/null
#	psql $(DBNAME) -f functions.sql > /dev/null
#	psql $(DBNAME) -f views.sql > /dev/null
#	psql $(DBNAME) -f cdf-fault-age.sql > /dev/null

populate-study:
	psql $(DBNAME) -f populate-versions.sql #> /dev/null
	psql $(DBNAME) -f init-study_tables.sql #> /dev/null
	./update-release-commit.sh

populate-funcs: populate-funcs.sql
	psql $(DBNAME) -f $< > /dev/null

populate-files: populate-files.sql
	psql $(DBNAME) -f $< > /dev/null

populate-files.sql: versions.txt
	./populate-files.sh > $@

%.sql: versions.txt %.sh
	./$(patsubst %.sql,%.sh,$@) > $@

tidy:
	rm -f *~

clean:

cleanall: clean
	rm -f populate-files.sql populate-funcs.sql

distclean: cleanall

