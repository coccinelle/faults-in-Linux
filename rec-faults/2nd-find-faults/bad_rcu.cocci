// use argument -D fn=xxx for the name of the freeing function of interest

virtual external

@free@
identifier virtual.fn;
position p1;
@@

fn@p1(...)

@script:python depends on !external@
p1 << free.p1;
defining_file << virtual.defining_file;
@@

defining_file = "%s" % defining_file # convert a cocci string to a python one
if (not(p1[0].file == defining_file)):
 cocci.include_match(False)

@locked exists@
position free.p1,p2;
identifier virtual.fn;
@@

(
rcu_read_lock@p2
|
rcu_read_lock_bh@p2
|
rcu_read_lock_sched@p2
|
rcu_read_lock_sched_notrace@p2
|
srcu_read_lock@p2
)
 (...)
... when != rcu_read_unlock
    when != rcu_read_unlock_bh
    when != rcu_read_unlock_sched
    when != rcu_read_unlock_sched_notrace
    when != srcu_read_unlock
fn@p1(...)

@script:python@
fn << virtual.fn;
p1 << free.p1;
p2 << locked.p2;
@@

cocci.print_main(fn,p1)
cocci.print_secs("ref",p2)
