// use argument -D fn=xxx for the name of the freeing function of interest

virtual external

@free@
identifier virtual.fn;
position p1;
@@

fn@p1(...)

@relevant@
@@

(
read_lock_irq(...)
|
write_lock_irq(...)
|
read_lock_irqsave(...)
|
write_lock_irqsave(...)
|
spin_lock_irq(...)
|
spin_lock_irqsave(...)
)

@script:python depends on !external && relevant@
p1 << free.p1;
defining_file << virtual.defining_file;
@@

defining_file = "%s" % defining_file # convert a cocci string to a python one
if (not(p1[0].file == defining_file)):
 cocci.include_match(False)

@locked exists@
expression lock;
position free.p1,p2;
identifier virtual.fn;
@@

(
read_lock_irq@p2
|
write_lock_irq@p2
|
read_lock_irqsave@p2
|
write_lock_irqsave@p2
|
spin_lock_irq@p2
|
spin_lock_irqsave@p2
)
 (lock,...)
... when != lock
fn@p1(...)

@script:python@
fn << virtual.fn;
p1 << free.p1;
p2 << locked.p2;
@@

cocci.print_main(fn,p1)
cocci.print_secs("ref",p2)
