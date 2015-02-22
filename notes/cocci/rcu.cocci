#include "cocci/database.cocci"

@rml@
position p;
@@

(
rcu_read_lock@p
|
rcu_read_lock_bh@p
|
rcu_read_lock_sched@p
|
rcu_read_lock_sched_notrace@p
|
srcu_read_lock@p
)
 ()

@script:python@
p << rml.p;
@@

add_note("rcu_lock",p,"rcu.cocci")
