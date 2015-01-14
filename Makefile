

all:

update-branches:
	git checkout orig.org && git merge master
	git checkout correl && git merge orig.org
	git checkout edit.hybrid && git merge correl
	git checkout new.hybrid && git merge edit.hybrid
