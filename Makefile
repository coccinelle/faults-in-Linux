#HERODOTOS is set locally or automatically find by `which`
-include Makefile.local

HFLAGS=--hacks
CONF?=study.hc
BOLT_CONFIG?=debug.config

HOST=$(shell uname -n | cut -f1 -d"." | tr '-' '_')
PWD=$(shell pwd)
DIR=$(shell basename $(PWD))

CLUSTER=~npalix/herodotos/scripts/Makefile.inc

ifneq ("$(shell if [ -f $(CLUSTER) ]; then echo true ; else echo false; fi)", "false")
include $(CLUSTER)
else
include ~/herodotos/herodotos/scripts/Makefile.inc
#include /usr/local/share/herodotos/Makefile.inc
endif

.PHONY:: fix-bossa fix-palace fix-cluster pack exist.tbz2

$(CONF): $(CONF).base
	 cpp -P -undef -D$(HOST) $(@:%=%.base) > $@
fix-mc4:
	for f in `find results/ -name "*.org"`; do sed -i "s|/var/linuxes|/scratch/linuxes|g" $$f ; done

fix-bossa:
	for f in `find results/ -name "*.org"`; do sed -i "s|/home/palix/projects/linux|/var/linuxes|g" $$f ; done

fix-palace:
	for f in `find results/ -name "*.org"`; do sed -i "s|/var/storage/projects/linux|/var/linuxes|g" $$f ; done

fix-cluster:
	for f in `find results/ -name "*.org"`; do sed -i "s|/home/npalix|/var|g" $$f ; done

exist.tbz2:
	find results -name "*.exist" | xargs tar cjvf $@

pack:
	tar cjvf ../$(DIR)_$(CONF:%.hc=%)_data.tbz2 -C .. --exclude-vcs $(DIR)

