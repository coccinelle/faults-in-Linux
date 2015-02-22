

all:

update-branches:
	git checkout orig.org && git merge master
	git checkout correl && git merge orig.org
	git checkout edit.hybrid && git merge correl
	git checkout new.hybrid && git merge edit.hybrid

blob_dump:
	pg_dump -b -c -C -f $(PGDATABASE).$@ -F c -O -Z 9 -U $(USER) -W $(PGDATABASE)
