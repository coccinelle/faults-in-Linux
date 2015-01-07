@r exists@
position p1,p2;
expression lock;
@@

(
read_lock_irq@p1
|
write_lock_irq@p1
|
read_lock_irqsave@p1
|
write_lock_irqsave@p1
|
spin_lock_irq@p1
|
spin_lock_irqsave@p1
)
 (lock,...)
... when != lock
GFP_KERNEL@p2

@script:python@
p1 << r.p1;
p2 << r.p2;
@@
cocci.print_main("gfp_kernel",p2)
cocci.print_secs("lock",p1)
