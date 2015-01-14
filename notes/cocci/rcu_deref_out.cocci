#include "cocci/database.cocci"

@rml@
position p;
@@

rcu_dereference@p(...)

@script:python@
p << rml.p;
@@

add_note("rcu_deref_out",p,"rcu_deref_out.cocci")
