@re@
expression E;
position p;
@@

krealloc@p(E,...)

@script:python@
p << re.p;
@@

cocci.print_main("krealloc",p)
