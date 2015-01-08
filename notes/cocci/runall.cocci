#include "cocci/database.cocci"

@rc@
expression E;
position p;
@@

copy_from_user@p(E,...)

@script:python@
p << rc.p;
@@

add_note("copy",p,"runall.cocci")
@rf@
expression E;
position p;
@@

kfree@p(E)

@script:python@
p << rf.p;
@@

add_note("kfree",p,"runall.cocci")
@rg@
expression E;
position p;
@@

get_user@p(E,...)

@script:python@
p << rg.p;
@@

add_note("get",p,"runall.cocci")
@r@
position p;
expression E;
@@

(
local_irq_save(E@p,...)
|
save_and_cli(E@p,...)
|
cli@p(...)
|
local_irq_disable@p(...)
)

@script:python@
p << r.p;
@@

add_note("intr",p,"runall.cocci")

//@ri@
//expression *x;
//position p,p1;
//identifier fld;
//@@
//
//x@p1->fld@p
//
//@script:python@
//p << ri.p;
//p1 << ri.p1;
//@@
//
//for q in p:
// x = [q]
// add_note("isnull",x,"runall.cocci")
//for q in p1:
// x = [q]
// add_note("null_ref",x,"runall.cocci")
