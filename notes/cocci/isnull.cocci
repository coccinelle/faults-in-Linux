@ri@
expression *x;
position p;
@@

(
x@p == NULL
|
x@p != NULL
)

@script:python@
p << ri.p;
@@

cocci.print_main("isnull",p)
