@s@
expression E;
position p2;
@@

E = rcu_dereference@p2(...)

@r@
expression E,E1,E1;
identifier f;
position p1,s.p2;
@@

E = rcu_dereference@p2(...)
... when != rcu_read_lock()
    when != rcu_read_lock_bh()
    when != rcu_read_lock_sched()
    when != rcu_read_lock_sched_notrace()
    when != srcu_read_lock()
    when != E = E1
(
rcu_read_unlock()
|
rcu_read_unlock_bh()
|
rcu_read_unlock_sched()
|
rcu_read_unlock_sched_notrace()
|
srcu_read_unlock()
)
... when != rcu_read_lock()
    when != rcu_read_lock_bh()
    when != rcu_read_lock_sched()
    when != rcu_read_lock_sched_notrace()
    when != srcu_read_lock()
    when != E = E2
E->f@p1

@script:python@
p1 << r.p1;
p2 << s.p2;
f << r.f;
@@

cocci.print_main(f,p1)
cocci.print_secs("call",p2)

