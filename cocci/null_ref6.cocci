// Copyright: (C) 2010 Nicolas Palix, Suman Saha, Gael Thomas, Christophe Calves, Julia Lawall, Gilles Muller, LIP6, INRIA, DIKU.  GPLv2.

@pre@
expression x;
identifier fld;
@@

x->fld

@pr1 expression@
expression pre.x;
identifier pre.fld;
position p1;
@@

(
  (x != NULL) && ... && <+...x@p1->fld...+>
|
  (x == NULL) || ... || <+...x@p1->fld...+>
)

@pr2 expression@
expression pre.x,E2;
identifier pre.fld;
position p2;
@@

(
  (x != NULL && ...) ? <+...x@p2->fld...+> : ...
|
  (x == NULL || ...) ? E2 : <+...x@p2->fld...+>
)

@pr3@
expression pre.x;
identifier pre.fld;
position p;
@@

(
x = <+...x@p->fld...+>
|
ARRAY_SIZE(x@p->fld)
|
sizeof(x@p->fld)
|
container_of(x@p->fld,...)
)

@match exists@
expression pre.x, E;
identifier pre.fld,fld1;
position p1!={pr1.p1,pr2.p2,pr3.p},p2;
@@

x@p1->fld
... when != \(x = E\|&x\|x->fld1\)
 \(x@p2 == NULL\|x@p2 != NULL\)

@andassign@
position match.p1;
expression E1;
identifier pre.fld;
expression pre.x;
@@

E1 = &(<+...x@p1->fld...+>)

@other_match exists@
expression pre.x;
position match.p1,match.p2;
@@

(
 &x
|
 x = ...
)
... when != x@p1
x@p2

@other_match1 exists@
expression pre.x, E2;
position match.p1,match.p2;
@@

... when != \(x = E2\|&x\)
    when != x@p1
x@p2

@ script:python depends on !other_match && !other_match1 && !andassign@
p1 << match.p1;
p2 << match.p2;
fld << pre.fld;
@@

cocci.print_main(fld,p2)
cocci.print_secs(fld,p1)

