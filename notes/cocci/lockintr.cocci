@r_li@
expression E;
position p;
@@

(
read_lock_irq@p
|
write_lock_irq@p
|
read_lock_irqsave@p
|
write_lock_irqsave@p
|
spin_lock_irq@p
|
spin_lock_irqsave@p
) (...)

@script:python@
p << r_li.p;
@@

cocci.print_main("lockintr",p)
