// use argument -D fn=xxx for the name of the freeing function of interest

virtual external

@free@
identifier virtual.fn;
position p1;
@@

fn@p1(...)

// extra matching, but better glimpse behavior, since these should be rare in
// 2.6
@relevant@
@@

(
cli(...)
|
local_irq_disable(...)
|
local_irq_save(...)
|
save_and_cli(...)
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
cli@p2(...)
|
local_irq_disable@p2(...)
|
local_irq_save@p2(...)
|
save_and_cli@p2(...)
)
... when != restore_flags(...)
    when != sti(...)
    when != local_irq_enable(...)
    when != local_irq_restore(...)
fn@p1(...)

@script:python@
fn << virtual.fn;
p1 << free.p1;
p2 << locked.p2;
@@

cocci.print_main(fn,p1)
cocci.print_secs("ref",p2)
