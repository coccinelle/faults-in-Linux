// separate because needs -all_includes

#include "cocci/database.cocci"

@rnd expression@
position p;
type T, T1, T2;
T1 *x;
T2 **y;
typedef u8;
{void *, char *, unsigned char *, u8*} a;
{struct device,struct net_device} dev;
@@

(
dev.priv = ...
|
y = \(kmalloc\|kzalloc\)(<+...sizeof(T)...+>,...)
|
a = \(kmalloc\|kzalloc\)(<+...sizeof(T)...+>,...)
|
x@p = \(kmalloc\|kzalloc\)(<+...sizeof(T)...+>,...)
)

@script:python@
p << rnd.p;
@@

add_note("noderef",p,"size_notes.cocci")


@rnd1 expression@
position p!=rnd.p;
expression *x;
expression E;
@@

x@p = <+... sizeof(E) ...+>

@script:python@
p << rnd1.p;
@@

add_note("noderef",p,"size_notes.cocci")
