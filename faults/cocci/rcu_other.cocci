@a@
position p1,p2;
@@

rcu_read_lock@p1(...)
... when != rcu_read_lock_bh(...)
    when != rcu_read_lock_sched(...)
    when != rcu_read_lock_sched_notrace(...)
    when != srcu_read_lock(...)
(
rcu_read_unlock_bh@p2(...)
|
rcu_read_unlock_sched@p2(...)
|
rcu_read_unlock_sched_notrace@p2(...)
|
srcu_read_unlock@p2(...)
)

@script:python@
p1 << a.p1;
p2 << a.p2;
@@

cocci.print_main("lock",p1)
cocci.print_secs("unlock",p2)

@b@
position p1,p2;
@@

rcu_read_lock_bh@p1(...)
... when != rcu_read_lock(...)
    when != rcu_read_lock_sched(...)
    when != rcu_read_lock_sched_notrace(...)
    when != srcu_read_lock(...)
(
rcu_read_unlock@p2(...)
|
rcu_read_unlock_sched@p2(...)
|
rcu_read_unlock_sched_notrace@p2(...)
|
srcu_read_unlock@p2(...)
)

@script:python@
p1 << b.p1;
p2 << b.p2;
@@

cocci.print_main("lock",p1)
cocci.print_secs("unlock",p2)

@c@
position p1,p2;
@@

rcu_read_lock_sched@p1(...)
... when != rcu_read_lock_bh(...)
    when != rcu_read_lock(...)
    when != rcu_read_lock_sched_notrace(...)
    when != srcu_read_lock(...)
(
rcu_read_unlock_bh@p2(...)
|
rcu_read_unlock@p2(...)
|
rcu_read_unlock_sched_notrace@p2(...)
|
srcu_read_unlock@p2(...)
)

@script:python@
p1 << c.p1;
p2 << c.p2;
@@

cocci.print_main("lock",p1)
cocci.print_secs("unlock",p2)

@d@
position p1,p2;
@@

rcu_read_lock_sched_notrace@p1(...)
... when != rcu_read_lock_bh(...)
    when != rcu_read_lock_sched(...)
    when != rcu_read_lock(...)
    when != srcu_read_lock(...)
(
rcu_read_unlock_bh@p2(...)
|
rcu_read_unlock_sched@p2(...)
|
rcu_read_unlock@p2(...)
|
srcu_read_unlock@p2(...)
)

@script:python@
p1 << d.p1;
p2 << d.p2;
@@

cocci.print_main("lock",p1)
cocci.print_secs("unlock",p2)

@e@
position p1,p2;
@@

srcu_read_lock@p1(...)
... when != rcu_read_lock_bh(...)
    when != rcu_read_lock_sched(...)
    when != rcu_read_lock_sched_notrace(...)
    when != rcu_read_lock(...)
(
rcu_read_unlock_bh@p2(...)
|
rcu_read_unlock_sched@p2(...)
|
rcu_read_unlock_sched_notrace@p2(...)
|
rcu_read_unlock@p2(...)
)

@script:python@
p1 << e.p1;
p2 << e.p2;
@@

cocci.print_main("lock",p1)
cocci.print_secs("unlock",p2)
