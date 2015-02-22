@locked@
position p1;
expression E1;
position p;
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
) (E1@p,...);

@balanced@
position p1 != locked.p1;
position locked.p;
identifier lock,unlock;
expression x <= locked.E1;
expression E,locked.E1;
expression E2;
@@

if (E) {
 <+... when != E1
 lock(E1@p,...)
 ...+>
}
... when != E1
    when != \(x = E2\|&x\)
    when forall
if (E) {
 <+... when != E1
 unlock@p1(E1,...)
 ...+>
}

@r depends on !balanced exists@
expression x <= locked.E1;
expression locked.E1;
expression E2;
identifier lock;
position locked.p,p1,p2;
@@

lock@p1 (E1@p,...);
... when != E1
    when != \(x = E2\|&x\)
lock@p2 (E1,...);

@script:python@
p1 << r.p1;
p2 << r.p2;
lock << r.lock;
@@

cocci.print_main(lock,p1)
cocci.print_secs("second lock",p2)
