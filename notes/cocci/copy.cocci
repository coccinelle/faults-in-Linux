@rc@
expression E;
position p;
@@

copy_from_user@p(E,...)

@script:python@
p << rc.p;
@@

cocci.print_main("copy",p)
