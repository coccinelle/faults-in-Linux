virtual org

@r depends on org@
expression E1;
position p;
@@

(
read_lock_irq
|
write_lock_irq
|
read_lock_irqsave
|
write_lock_irqsave
|
local_irq_save
|
spin_lock_irq
|
spin_lock_irqsave
) (E1,...);
... when != E1
    when any
 anallocator(...,<+... GFP_KERNEL@p ...+>)

@script:python@
p << r.p;
@@

msg="%s::%s" % (p[0].file, p[0].line)
coccilib.org.print_todo(p[0], msg)
cocci.include_match(False)