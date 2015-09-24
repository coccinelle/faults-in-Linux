

all:

update-branches:
	git checkout collect && git merge master
	git checkout orig.org && git merge collect
	git checkout new.hybrid && git merge orig.org

blob_dump:
	pg_dump -b -c -C -f $(PGDATABASE).$@ -F c -O -Z 9 -U $(USER) -W $(PGDATABASE)

