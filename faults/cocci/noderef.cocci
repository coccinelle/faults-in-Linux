// no options

@r expression@
expression *x;
position p;
@@

x@p = <+... sizeof(x) ...+>

@script:python@
p << r.p;
@@

cocci.print_main("x",p)
