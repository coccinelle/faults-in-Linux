#include "cocci/database.cocci"

@gfp@
position p;
@@

GFP_KERNEL@p

@script:python@
p << gfp.p;
@@

add_note("block",p,"block_notes.cocci")
