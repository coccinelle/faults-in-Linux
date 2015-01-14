@rg@
expression E;
position p;
@@

get_user@p(E,...)

@script:python@
p << rg.p;
@@

cocci.print_main("get",p)
