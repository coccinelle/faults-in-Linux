#include "cocci/manage_static.cocci"

@fns exists@
expression E;
identifier virtual.alloc, fn;
type T;
identifier i;
position p;
@@

fn@p(T i, ...) { ... when != \(i = E\|&i\)
  alloc(i,...)
 ... when any
}

@r@
expression E;
identifier virtual.alloc, fns.fn;
type T;
identifier i;
position fns.p;
@@

fn@p(T i, ...) { ... when != \(i = E\|&i\)
                     when strict
  alloc(i,...)
 ... when any
}

@statfns@
identifier fns.fn;
position fns.p;
@@

static fn@p(...) { ... }

@script:python depends on r && statfns@
fn << fns.fn;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << fns.p;
@@

output_static("kfree1_all",fn,tmp,fl,version,"",p[0].file)

@script:python depends on r && !statfns@
fn << fns.fn;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << fns.p;
@@

output_external("kfree1_all",fn,tmp,fl,version,"")
