@r exists@
position p1,p2;
@@

(
spin_lock@p1
|
spin_trylock@p1
|
read_lock@p1
|
read_trylock@p1
|
write_lock@p1
|
write_trylock@p1
|
local_irq_save@p1
|
save_and_cli@p1
|
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
|
cli@p1
|
local_irq_disable@p1
)
 (...)
... when != spin_unlock
    when != read_unlock
    when != write_unlock
    when != local_irq_restore
    when != restore_flags
    when != read_unlock_irq
    when != write_unlock_irq
    when != read_unlock_irqrestore
    when != write_unlock_irqrestore
    when != spin_unlock_irq
    when != spin_unlock_irqrestore
    when != sti
    when != local_irq_enable
GFP_KERNEL@p2

@script:python@
p1 << r.p1;
p2 << r.p2;
@@
cocci.print_main("lock",p1)
cocci.print_secs("gfp_kernel",p2)
