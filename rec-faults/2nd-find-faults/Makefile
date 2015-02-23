SHELL=/bin/bash
HFLAGS=--hacks
CONF=bad_kfree.hc
#CONF=save_bad_kfree.hc

###################################
-include ../../Makefile.local

HERODOTOS=~/herodotos/herodotos/herodotos
HOST=$(shell uname -n | cut -f1 -d"." | tr '-' '_')
PWD=$(shell pwd)
DIR=$(shell basename $(PWD))

include /usr/local/share/herodotos/Makefile.inc

.PHONY:: pack

$(CONF): $(CONF).base
	 cpp -P -D$(HOST) $^ | sed "s|/1 |/linux|" > $@

pack:
	tar cjvf ../$(DIR)_$(CONF:%.hc=%)_data.tbz2 -C .. --exclude-vcs $(DIR)

-include Makefile.local
