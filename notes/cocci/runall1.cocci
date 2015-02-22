#include "cocci/database.cocci"

@rml@
position p,p1;
expression E;
@@

(
mutex_lock@p1
|
mutex_trylock@p1
|
spin_lock@p1
|
spin_trylock@p1
|
read_lock@p1
|
read_trylock@p1
|
write_lock@p1
|
write_trylock@p1
)
 (E@p,...)

@script:python@
p << rml.p;
p1 << rml.p1;
@@

add_note("lock",p,"runall1.cocci")
add_note("double_lock",p1,"runall1.cocci")

@r_li@
position p,p1;
expression E;
@@

(
read_lock_irq@p1
|
write_lock_irq@p1
|
read_lock_irqsave@p1
|
write_lock_irqsave@p1
|
spin_lock_irq@p1
|
spin_lock_irqsave@p1
) (E@p,...)

@script:python@
p << r_li.p;
p1 << r_li.p1;
@@

add_note("lockintr",p,"runall1.cocci")
add_note("double_lockintr",p1,"runall1.cocci")

@re@
expression E;
position p;
@@

krealloc@p(E,...)

@script:python@
p << re.p;
@@

add_note("krealloc",p,"runall1.cocci")

@var@
type T;
identifier i;
expression E;
position p;
@@

T i[E@p];


@script:python@
p << var.p;
@@

add_note("var",p,"runall1.cocci")

