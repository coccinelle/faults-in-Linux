@pr1 expression@
expression E;
identifier f;
position p1;
@@

(
  (E != NULL) && ... && <+...E@p1->f...+>
|
  (E == NULL) || ... || <+...E@p1->f...+>
)

@pr2 expression@
expression E,E2;
identifier f;
position p2;
@@

(
  (E != NULL && ...) ? <+...E@p2->f...+> : ...
|
  (E == NULL || ...) ? E2 : <+...E@p2->f...+>
)

@match exists@
expression x, E, E1;
identifier fld;
position p1!={pr1.p1,pr2.p2},p2;
@@

(
break;
|
x = <+...x->fld...+>
|
ARRAY_SIZE(x->fld)
|
sizeof(x->fld)
|
E1 = &(<+...x->fld...+>)  // false neg if x->fld is eg in an array index
... when != \(x = E\|&x\|E1\)
 \(x@p2 == NULL\|x@p2 != NULL\)
... when any
|
x@p1->fld
... when != \(x = E\|&x\)
 \(x@p2 == NULL\|x@p2 != NULL\)
... when any
)

@other_match exists@
expression match.x;
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
expression match.x, E2;
position match.p1,match.p2;
@@

... when != \(x = E2\|&x\)
    when != x@p1
x@p2

@ script:python depends on !other_match && !other_match1@
p1 << match.p1;
p2 << match.p2;
@@

for q in p1:
 x = [q]
 cocci.print_main("deref",x)
 cocci.print_secs("test",p2)
