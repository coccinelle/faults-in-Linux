#include "cocci/database.cocci"

@ref@
expression x;
identifier fld;
@@

x->fld

@fn exists@
identifier f;
expression ref.x;
identifier fld;
@@

f(...) {  ... when any
   x->fld ... when any
 }

@test exists@
expression ref.x;
identifier fn.f;
position p;
@@

f(...) { <...
(
 x@p == NULL
|
 x@p != NULL
|
 (x@p || ...)
)
...> }

@script:python@
p << test.p;
@@

add_note("inull",p,"inull_notes.cocci")
//for sp in p:
//	print sp.line, sp.column

