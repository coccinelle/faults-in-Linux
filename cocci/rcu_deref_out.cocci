// Copyright: (C) 2010 Nicolas Palix, Suman Saha, Gael Thomas, Christophe Calves, Julia Lawall, Gilles Muller, LIP6, INRIA, DIKU.  GPLv2.

// rcu_dereference outside of rcu_lock

@r@
position p1;
position p2;
@@

rcu_dereference@p1(...)
... when != rcu_read_unlock()
    when != rcu_read_unlock_bh()
    when != rcu_read_unlock_sched()
    when != rcu_read_unlock_sched_notrace()
    when != srcu_read_unlock()
(
rcu_read_lock@p2()
|
rcu_read_lock_bh@p2()
|
rcu_read_lock_sched@p2()
|
rcu_read_lock_sched_notrace@p2()
|
srcu_read_lock@p2()
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

cocci.print_main("deref",p1)
cocci.print_secs("lock",p2)

