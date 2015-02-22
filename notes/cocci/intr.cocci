@r@
expression E;
position p;
@@

(
local_irq_save@p
|
save_and_cli@p
|
cli@p
|
local_irq_disable@p
) (...)

@script:python@
p << r.p;
@@

cocci.print_main("intr",p)
