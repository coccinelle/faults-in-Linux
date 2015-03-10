#############################################################################
# Configuration section
#############################################################################

CHOME?=~/coccinelle

-include Makefile.config
-include /etc/lsb-release

##############################################################################
# Variables
##############################################################################
TARGET=count_lines
PRJNAME=coccinelle

#SRC=flag_cocci.ml main_ages.ml
SRC=flag_cocci.ml middle_churn.ml
SRC=flag_cocci.ml main.ml

ifeq ($(FEATURE_PYTHON),1)
PYCMA=pycaml.cma
# the following is essential for Coccinelle to compile under gentoo (weird)
#OPTLIBFLAGS=-cclib dllpycaml_stubs.so
else
PYCMA=
endif
OPTLIBFLAGS=

ifeq ("$(SEXPDIR)","ocamlsexp")
SEXPLIB=sexplib.cmo
OPTSEXPLIB=sexplib.cmx
else
SEXPLIB=sexplib.cma
OPTSEXPLIB=sexplib.cmxa
endif

SEXPSYSCMA=bigarray.cma nums.cma

SYSLIBS=str.cma unix.cma $(SEXPSYSCMA) dynlink.cma
LIBS=$(CHOME)/commons/commons.cma \
     $(CHOME)/globals/globals.cma \
     $(CHOME)/parsing_cocci/cocci_parser.cma $(CHOME)/parsing_c/parsing_c.cma \
     $(CHOME)/extra/extra.cma
#	$(CHOME)/commons/commons_sexp.cma \

# Should we use the local version of pycaml
ifeq ("$(PYCAMLDIR)","pycaml")
LOCALPYCAML=pycaml
else
LOCALPYCAML=
endif

# Should we use the local version of menhirLib
ifeq ("$(MENHIRDIR)","menhirLib")
LOCALMENHIR=menhirLib
MAKESUBDIRS+=$(CHOME)/$(LOCALMENHIR) 
else
LOCALMENHIR=
endif

# Should we use the local version of ocamlsexp
ifeq ("$(SEXPDIR)","ocamlsexp")
LOCALSEXP=ocamlsexp
MAKESUBDIRS+=$(CHOME)/$(LOCALSEXP)
else
LOCALSEXP=
endif

#used for clean: and depend: and a little for rec & rec.opt
MAKESUBDIRS+=$(CHOME)/commons $(CHOME)/globals $(CHOME)/parsing_cocci $(CHOME)/parsing_c

INCLUDEDIRSDEP=$(CHOME)/commons $(CHOME)/commons/ocamlextra \
 $(CHOME)/globals \
 $(CHOME)/parsing_cocci $(CHOME)/parsing_c

INCLUDEDIRS=$(INCLUDEDIRSDEP) $(SEXPDIR) $(MENHIRDIR)

##############################################################################
# Generic variables
##############################################################################

INCLUDES=$(INCLUDEDIRS:%=-I %)

OBJS=    $(SRC:.ml=.cmo)
OPTOBJS= $(SRC:.ml=.cmx)

EXEC=$(TARGET)

##############################################################################
# Generic ocaml variables
##############################################################################

OCAMLCFLAGS= -g # -dtypes # -w A

# for profiling add  -p -inline 0
# but 'make forprofiling' below does that for you.
# This flag is also used in subdirectories so don't change its name here.
# To enable backtrace support for native code, you need to put -g in OPTFLAGS
# to also link with -g, but even in 3.11 the backtrace support seems buggy so
# not worth it.
OPTFLAGS=
# the following is essential for Coccinelle to compile under gentoo
# but is now defined above in this file

OCAMLC=ocamlc$(OPTBIN) $(OCAMLCFLAGS)  $(INCLUDES)
OCAMLOPT=ocamlopt$(OPTBIN) $(OPTFLAGS) $(INCLUDES)
OCAMLLEX=ocamllex #-ml # -ml for debugging lexer, but slightly slower
OCAMLYACC=ocamlyacc -v
OCAMLDEP=ocamldep $(INCLUDES)
OCAMLMKTOP=ocamlmktop -g -custom $(INCLUDES)

# can also be set via 'make static'
STATIC= #-ccopt -static

# can also be unset via 'make purebytecode'
BYTECODE_STATIC=-custom

##############################################################################
# Top rules
##############################################################################
.PHONY:: all all.opt byte opt top clean distclean configure
.PHONY:: $(MAKESUBDIRS) $(MAKESUBDIRS:%=%.opt) subdirs subdirs.opt

all: Makefile.config byte

opt: all.opt
all.opt: opt-compil

world:
	$(MAKE) byte
	$(MAKE) opt-compil

byte: .depend
	$(MAKE) subdirs
	$(MAKE) $(EXEC)

opt-compil: .depend
	$(MAKE) subdirs.opt
	$(MAKE) $(EXEC).opt

top: $(EXEC).top

subdirs:
	$(MAKE) -C $(CHOME)/commons OCAMLCFLAGS="$(OCAMLCFLAGS)"
#	$(MAKE) -C $(CHOME)/commons sexp OCAMLCFLAGS="$(OCAMLCFLAGS)"
	+for D in $(MAKESUBDIRS); do $(MAKE) $$D || exit 1 ; done

subdirs.opt:
	$(MAKE) -C $(CHOME)/commons all.opt OCAMLCFLAGS="$(OCAMLCFLAGS)"
#	$(MAKE) -C $(CHOME)/commons sexp.opt OCAMLCFLAGS="$(OCAMLCFLAGS)"
	+for D in $(MAKESUBDIRS); do $(MAKE) $$D.opt || exit 1 ; done

$(MAKESUBDIRS):
	$(MAKE) -C $@ OCAMLCFLAGS="$(OCAMLCFLAGS)" all

$(MAKESUBDIRS:%=%.opt):
	$(MAKE) -C $(@:%.opt=%) OCAMLCFLAGS="$(OCAMLCFLAGS)" all.opt

#dependencies:
# commons:
# globals:
# menhirlib:
# parsing_cocci: commons globals menhirlib
# parsing_c:parsing_cocci
# ctl:globals commons
# engine: parsing_cocci parsing_c ctl
# popl09:engine
# extra: parsing_cocci parsing_c ctl

clean::
	set -e; for i in $(MAKESUBDIRS); do $(MAKE) -C $$i $@; done

$(LIBS): $(MAKESUBDIRS)
$(LIBS:.cma=.cmxa): $(MAKESUBDIRS:%=%.opt)

$(OBJS):$(LIBS)
$(OPTOBJS):$(LIBS:.cma=.cmxa)

$(EXEC): $(LIBS) $(OBJS)
	$(OCAMLC) $(BYTECODE_STATIC) -o $@ $(SYSLIBS)  $^

$(EXEC).opt: $(LIBS:.cma=.cmxa) $(OPTOBJS)
	$(OCAMLOPT) $(STATIC) -o $@ $(SYSLIBS:.cma=.cmxa) $(OPTLIBFLAGS)  $^

$(EXEC).top: $(LIBS) $(OBJS)
	$(OCAMLMKTOP) -custom -o $@ $(SYSLIBS) $^

clean::
	rm -f $(TARGET) $(TARGET).opt $(TARGET).top


.PHONY:: configure

configure:
	./configure

Makefile.config:
	@echo "Makefile.config is missing. Have you run ./configure?"
	@exit 1

static:
	rm -f spatch.opt spatch
	$(MAKE) STATIC="-ccopt -static" spatch.opt
	cp spatch.opt spatch

purebytecode:
	rm -f spatch.opt spatch
	$(MAKE) BYTECODE_STATIC="" spatch

##############################################################################
# Generic ocaml rules
##############################################################################

.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	$(OCAMLC)    -c $<
.mli.cmi:
	$(OCAMLC)    -c $<
.ml.cmx:
	$(OCAMLOPT)  -c $<

.ml.mldepend:
	$(OCAMLC) -i $<

clean::
	rm -f *.cm[iox] *.o *.annot
	rm -f *~ .*~ *.exe #*#

beforedepend::

depend:: beforedepend
	$(OCAMLDEP) *.mli *.ml > .depend
	set -e; for i in $(MAKESUBDIRS); do $(MAKE) -C $$i $@; done

.depend::
	@if [ ! -f .depend ] ; then $(MAKE) depend ; fi

-include .depend

churn.jgr: churn.jgr.base arch_data driver_data fs_data net_data
	jgraph -p $@.base > $@

IMAGES_JGR=churn.jgr

-include ../../figures/Makefile.images
