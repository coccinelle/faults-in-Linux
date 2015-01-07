// cli(); / sti();
// local_irq_disable(); / local_irq_enable();

@ends_in_lock exists@
identifier virtual.lock;
identifier virtual.unlock;
position p,p2;
identifier f;
@@

f (...) { <+...
lock@p();
... when != \(unlock\|restore_flags\)(...);
return@p2 ...;
...+> }

@ends_in_unlock exists@
identifier virtual.lock;
identifier virtual.unlock;
identifier ends_in_lock.f;
@@

f (...) { <+...
unlock();
... when != lock(...);
return ...;
...+> }

@balanced depends on ends_in_lock && ends_in_unlock exists@
position ends_in_lock.p;
identifier virtual.lock;
identifier virtual.unlock;
identifier ends_in_lock.f;
expression E;
@@

f (...) { <+...
if (E) {
 <+... when != lock()
 lock@p()
 ...+>
}
... when != \(unlock\|restore_flags\)(...)
    when forall
if (E) {
 <+... when != \(unlock\|restore_flags\)(...)
 \(unlock\|restore_flags\)(...)
 ...+>
}
...+> }

@script:python depends on ends_in_lock && ends_in_unlock && !balanced@
p << ends_in_lock.p;
p2 << ends_in_lock.p2;
lock << virtual.lock;
@@

cocci.print_main(lock,p)
cocci.print_secs("return",p2)
