// first appeared in Linux 2.6.22

@ r @
type T;
expression id;
position p;
@@

id = (T)krealloc@p(id,...)

@script: python@
id << r.id;
p << r.p;
@@

cocci.print_main("krealloc",p)
