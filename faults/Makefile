CONF?=study.hc
MINVER=3.1
VER=3.19
#bad_lock3a bad_lock4a bad_lock5a  bad_null2 bad_null3 bad_kfree
PATTERNS=block1a block1b block1c var isnull5 null_ref6 copy get  \
	double_lock2 lock intr intr_noarg_cli_sti \
	intr_noarg_local_irq_enable_disable \
	double_lockintr2 lockintr kfree floatop realloc noderef  \
	size_rule
# rcu_lock rcu_lock_bh rcu_lock_sched rcu_lock_sched_notrace srcu_lock bad_rcu rcu_deref_out

#HERODOTOS is set locally or automatically find by `which`
-include ../Makefile.local

HFLAGS=--hacks --diff hybrid $(PATT)
HOST=$(shell uname -n | cut -f1 -d"." | tr '-' '_')
PWD=$(shell pwd)
DIR=$(shell basename $(PWD))
NEW=$(PATTERNS:%=results/linuxes/Linux_%.new.org)

include /usr/local/share/herodotos/Makefile.inc

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

extract:
	mkdir -p v$(VER)
	cd results/linuxes/ ; find -name "Linux_*.new.org" -exec $(HERODOTOS) extract --orgfile \{} --tag linux-$(VER) --prefix /scratch/linuxes/ -o ../../v$(VER)/\{} \;


EXPORT=$(PATT:%=export-%)
export: $(EXPORT)
$(EXPORT): $(NEW)
	$(HERODOTOS) export-reports --prefix /fast_scratch/linuxes/ \
		--orgfile results/linuxes/Linux_$@.new.org \
		--to-sql-update linux-$(MINVER)

