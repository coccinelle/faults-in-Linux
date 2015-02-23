virtual after_start

@initialize:ocaml@

let tbl = Hashtbl.create(100)

let add_if_not_present from f file =
try let _ = Hashtbl.find tbl (f,file) in ()
with Not_found ->
   Hashtbl.add tbl (f,file) file;
   Printf.printf "# from %s to %s\n" from f;
   let it = new iteration() in
   (match file with
     Some fl ->
      Printf.printf "-D fn=%s -D defining_file=%s\n" f fl;
      it#set_files [fl]
   | None -> Printf.printf "-D fn=%s -D external\n" f);
   it#add_virtual_rule After_start;
   it#add_virtual_identifier Alloc f;
   it#register()

// consider whether the return should be under an if

@r depends on !after_start exists@
expression x,y,E;
identifier alloc, fn;
type T;
position p,rn;
identifier fld;
@@

T *fn@p(...) { <+...
(
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

@statfns@
identifier r.fn;
position r.p;
@@

static fn@p(...) { ... }

@script:ocaml depends on statfns@
fn << r.fn;
p << r.p;
rn << r.rn;
@@

add_if_not_present "NULL" fn (Some ((List.hd p).file))

@script:ocaml depends on !statfns@
fn << r.fn;
p << r.p;
rn << r.rn;
@@

add_if_not_present "NULL" fn None

// -----------------------------------------------------------------------

@base depends on !after_start@
position pb;
@@

 \(kmalloc@pb\|kzalloc@pb\|kcalloc@pb\|kmalloc_node@pb\|kzalloc_node@pb\|kmem_cache_alloc@pb\|kmem_cache_zalloc@pb\)(...)

@k depends on !after_start exists@
expression x,E;
identifier fn;
type T;
position p,base.pb,rn;
identifier fld;
identifier alloc;
@@

T *fn@p(...) { <+...
(
 return@rn alloc@pb(...);
|
 if (unlikely((x = alloc@pb(...)) == NULL) || ...) {
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
  x = alloc@pb(...)
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

@statfns_callb@
identifier k.fn;
position k.p;
@@

static fn@p(...) { ... }

@script:ocaml depends on statfns_callb@
fn << k.fn;
p << k.p;
rn << k.rn;
alloc << k.alloc;
@@

add_if_not_present alloc fn (Some ((List.hd p).file))

@script:ocaml depends on !statfns_callb@
fn << k.fn;
p << k.p;
rn << k.rn;
alloc << k.alloc;
@@

add_if_not_present alloc fn None

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

@script:ocaml depends on statfns_call@
fn << s.fn;
p << s.p;
rn << s.rn;
alloc << virtual.alloc;
@@

add_if_not_present alloc fn (Some ((List.hd p).file))

@script:ocaml depends on !statfns_call@
fn << s.fn;
p << s.p;
rn << s.rn;
alloc << virtual.alloc;
@@

add_if_not_present alloc fn None
