virtual after_start

// consider whether the return should be under an if

#include "cocci/manage_static.cocci"

@r depends on !after_start exists@
expression x,y,E;
identifier alloc, fn;
type T;
position p,rn;
identifier fld;
@@

T *fn@p(...) { <+...
(
 return@rn (NULL);
|
 if (unlikely((x = alloc(...)) == NULL) || ...) {
  ... when != x = E
      when != &x
      when != x->fld
(
     return@rn (x);
|
     return@rn (NULL);
|
     return y;
)
}
|
  x = alloc(...)
  ... when != x = E
      when != &x
      when != x->fld
      when != false unlikely(x == NULL)
      when != true likely(x != NULL)
  if (unlikely(x == NULL) || ...)
 { ... when != x = E
       when != &x
(
        return@rn (x);
|
        return@rn (NULL);
|
        return y;
)
 ...}
)
...+> }

@script:python@
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << r.p;
@@

if not started:
  started = True
  output_external("null3","kmalloc",tmp,fl,version,"-D after_start")
  output_external("null3","kzalloc",tmp,fl,version,"-D after_start")
  output_external("null3","kcalloc",tmp,fl,version,"-D after_start")
  output_external("null3","kmalloc_node",tmp,fl,version,"-D after_start")
  output_external("null3","kzalloc_node",tmp,fl,version,"-D after_start")
  output_external("null3","kmem_cache_alloc",tmp,fl,version,"-D after_start")
  output_external("null3","kmem_cache_zalloc",tmp,fl,version,"-D after_start")

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

output_static("null3",fn,tmp,fl,version,"-D after_start",p[0].file)

@script:python depends on !statfns@
fn << r.fn;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << r.p;
rn << r.rn;
@@

output_external("null3",fn,tmp,fl,version,"-D after_start")

// -----------------------------------------------------------------------

@s depends on after_start exists@
expression x,E;
identifier virtual.alloc, fn;
type T;
position p,rn;
identifier fld;
@@

T *fn@p(...) { <+...
(
 return@rn alloc(...);
|
 if (unlikely((x = alloc(...)) == NULL) || ...) {
  ... when != x = E
      when != &x
      when != x->fld
(
     return@rn (x);
|
     return ...;
)
}
|
  x = alloc(...)
  ... when != x = E
      when != &x
      when != x->fld
      when != false unlikely(x == NULL)
      when != false unlikely(NULL == x)
      when != true likely(x != NULL)
      when != IS_ERR(x)
  return@rn (x);
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
alloc << virtual.alloc;
@@

str = "echo call stat %s to %s in %s && " % (fn,alloc,p[0].file)
print str,
output_static("null3",fn,tmp,fl,version,"-D after_start",p[0].file)

@script:python depends on !statfns_call@
fn << s.fn;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << s.p;
rn << s.rn;
alloc << virtual.alloc;
@@

str = "echo call ext %s to %s in %s && " % (fn,alloc,p[0].file)
print str,
output_external("null3",fn,tmp,fl,version,"-D after_start")
