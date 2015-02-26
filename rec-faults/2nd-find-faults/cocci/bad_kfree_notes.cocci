// use argument -D fn=xxx for the name of the freeing function of interest

virtual check_for_static, external

@free@
identifier virtual.fn;
position p1;
@@

fn@p1(...)

@script:python depends on check_for_static@
p1 << free.p1;
defining_file << virtual.defining_file;
@@

defining_file = "%s" % defining_file # convert a cocci string to a python one
if (not(p1[0].file == defining_file)):
 cocci.include_match(False)

@script:python@
fn << virtual.fn;
p1 << free.p1;
@@

cocci.print_main(fn,p1)
