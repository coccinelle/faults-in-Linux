@ends_in_lock exists@
position p,p2;
identifier f;
identifier virtual.rcu_read_lock;
identifier virtual.rcu_read_unlock;
@@

f (...) { <+...
rcu_read_lock@p();
... when != rcu_read_unlock(...);
return@p2 ...;
...+> }

@ends_in_unlock exists@
identifier ends_in_lock.f;
identifier virtual.rcu_read_lock;
identifier virtual.rcu_read_unlock;
@@

f (...) { <+...
rcu_read_unlock();
... when != rcu_read_lock(...);
return ...;
...+> }

@balanced depends on ends_in_lock && ends_in_unlock exists@
position ends_in_lock.p;
identifier ends_in_lock.f;
identifier virtual.rcu_read_lock;
identifier virtual.rcu_read_unlock;
expression E;
@@

f (...) { <+...
if (E) {
 <+... when != rcu_read_lock()
 rcu_read_lock@p()
 ...+>
}
... when != rcu_read_unlock(...)
    when forall
if (E) {
 <+... when != rcu_read_unlock(...)
 rcu_read_unlock(...)
 ...+>
}
...+> }

@script:python depends on ends_in_lock && ends_in_unlock && !balanced@
p << ends_in_lock.p;
p2 << ends_in_lock.p2;
@@

cocci.print_main("lock",p)
cocci.print_secs("return",p2)
