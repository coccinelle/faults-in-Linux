@r exists@
position p1,p2;
@@

(
cli@p1(...)
|
local_irq_disable@p1(...)
|
local_irq_save@p1(...)
|
save_and_cli@p1(...)
)
... when != restore_flags(...)
    when != sti(...)
    when != local_irq_enable(...)
    when != local_irq_restore(...)
GFP_KERNEL@p2

@script:python@
p1 << r.p1;
p2 << r.p2;
@@
cocci.print_main("gfp_kernel",p2)
cocci.print_secs("lock",p1)
