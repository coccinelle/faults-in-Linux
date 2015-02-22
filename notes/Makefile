
CONF=notes.hc

###################################
#HERODOTOS is defined locally (or automatically with which)
-include ../Makefile.local

HOST=$(shell uname -n | cut -f1 -d"." | tr '-' '_')
PWD=$(shell pwd)
DIR=$(shell basename $(PWD))

include /usr/local/share/herodotos/Makefile.inc

all:: /usr/share/pyshared/psycopg2/__init__.py

$(CONF): $(CONF).base 
	 cpp -P -D$(HOST) $^ | sed "s|/1 |/linux|" > $@
