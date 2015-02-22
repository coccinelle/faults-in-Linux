@locked@
position p1;
expression E1;
position p;
@@

(
spin_lock_bh@p1
|
read_lock_bh@p1
|
write_lock_bh@p1
) (E1@p,...);

@doubled exists@
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

@balanced depends on doubled@
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

@script:python depends on !balanced@
p1 << doubled.p1;
p2 << doubled.p2;
p << locked.p;
lock << doubled.lock;
@@

cocci.print_main(lock,p1)
cocci.print_secs("second lock",p2)
