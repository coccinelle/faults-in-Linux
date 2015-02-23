// use argument -D fn=xxx for the name of the null returning function of
// interest
// -no_includes -include_headers

virtual external

@call@
identifier virtual.fn;
position p1;
expression E;
@@

E@p1 = fn(...)

@script:python depends on !external@
p1 << call.p1;
defining_file << virtual.defining_file;
@@

defining_file = "%s" % defining_file # convert a cocci string to a python one
if (not(p1[0].file == defining_file)):
 cocci.include_match(False)

@script:python@
fn << virtual.fn;
p1 << call.p1;
@@

for q in p1:
 cocci.print_main(fn,[q])
