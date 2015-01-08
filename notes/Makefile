
CONF=notes.hc

###################################
#HERODOTOS is defined locally (or automatically with which)
-include ../faults/Makefile.local

HOST=$(shell uname -n | cut -f1 -d"." | tr '-' '_')
PWD=$(shell pwd)
DIR=$(shell basename $(PWD))

include /usr/local/share/herodotos/Makefile.inc

.PHONY:: fix-palace pack

$(CONF): $(CONF).base 
	 cpp -P -D$(HOST) $^ | sed "s|/1 |/linux|" > $@

fix-palace:
	for f in `find results/ -name "*.org"`; do sed -i "s|/var/storage/projects/linux|/var/linuxes|g" $$f ; done

pack:
	tar cjvf ../$(DIR)_$(CONF:%.hc=%)_data.tbz2 -C .. --exclude-vcs $(DIR)
