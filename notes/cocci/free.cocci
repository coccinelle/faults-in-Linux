@rf@
expression E;
position p;
@@

kfree@p(E)

@script:python@
p << rf.p;
@@

cocci.print_main("kfree",p)
