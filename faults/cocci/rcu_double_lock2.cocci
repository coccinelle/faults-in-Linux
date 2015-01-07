@doubled exists@
position p1,p2;
@@

rcu_read_lock@p1 ();
... when != rcu_read_unlock()
rcu_read_lock@p2 ();

@balanced depends on doubled@
expression E;
position doubled.p1,doubled.p2;
@@

if (E) {
 <+...
 rcu_read_lock@p1()
 ...+>
}
... when != rcu_read_unlock()
    when != rcu_read_lock@p2()
    when forall
if (E) {
 <+...
 rcu_read_unlock()
 ...+>
}

@script:python depends on !balanced@
p1 << doubled.p1;
p2 << doubled.p2;
@@

cocci.print_main("lock",p1)
cocci.print_secs("second lock",p2)
