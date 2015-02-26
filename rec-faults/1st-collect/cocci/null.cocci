virtual after_start

// consider whether the return should be under an if

#include "cocci/manage_static.cocci"

@a depends on !after_start exists@
identifier fn;
iterator I;
position p;
@@

fn@p(...) {
  <+...
(
  while(...) { <+... return ...; ...+> }
|
  for(...;...;...) { <+... return ...; ...+> }
|
  I(...) { <+... return ...; ...+> }
)
(
  return ... ? ... : NULL;
|
  return NULL;
)
  ...+>
}

@r depends on !after_start exists@
expression x,y,E;
identifier fn,fld;
position p!=a.p,rn;
@@

fn@p(...) { <+...
(
  return@rn ... ? ... : NULL;
|
  return@rn (NULL);
|
  x = \( NULL \| ... ? ... : NULL \)
  ... when != x = E
      when != &x
      when != x->fld
      when != false unlikely(x == NULL)
      when != true likely(x != NULL)
(
  if (x == NULL || ...) { ... when forall
(
        return@rn (x);
|
        return@rn ... ? ... : (x);
|
        return y;
)
 ...}
|
  return@rn (x);
|
  return@rn ... ? ... : (x);
)
)
...+> }

@statfns@
identifier r.fn;
position r.p;
@@

static fn@p(...) { ... }

@script:python depends on statfns@
fn << r.fn;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << r.p;
rn << r.rn;
@@

output_static("null",fn,tmp,fl,version,"-D after_start",p[0].file)

@script:python depends on !statfns@
fn << r.fn;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << r.p;
rn << r.rn;
@@

output_external("null",fn,tmp,fl,version,"-D after_start")

// -----------------------------------------------------------------------

@s depends on after_start exists@
expression x,y,E;
identifier virtual.alloc, fn;
type T;
position p,rn;
identifier fld;
@@

T *fn@p(...) { <+...
(
 return@rn alloc(...);
|
  x = alloc(...)
  ... when != x = E
      when != &x
      when != x->fld
      when != false unlikely(x == NULL)
      when != true likely(x != NULL)
(
  if (x == NULL || ...) { ... when forall
(
        return@rn (x);
|
        return@rn ... ? ... : (x);
|
        return y;
)
 ...}
|
  return@rn (x);
|
  return@rn ... ? ... : (x);
)
)
...+> }

@statfns_call@
identifier s.fn;
position s.p;
@@

static fn@p(...) { ... }

@script:python depends on statfns_call@
fn << s.fn;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << s.p;
rn << s.rn;
@@

output_static("null",fn,tmp,fl,version,"-D after_start",p[0].file)

@script:python depends on !statfns_call@
fn << s.fn;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << s.p;
rn << s.rn;
@@

output_external("null",fn,tmp,fl,version,"-D after_start")
