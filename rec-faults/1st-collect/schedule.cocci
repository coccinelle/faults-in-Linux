virtual after_start

#include "manage_static.cocci"

@gfp depends on !after_start exists@
identifier fn != {panic};
position p,p1;
@@

fn@p(...) {
... when != mutex_unlock
    when != spin_unlock
    when != read_unlock
    when != write_unlock
    when != up
    when != local_irq_restore
    when != restore_flags
    when != read_unlock_irq
    when != write_unlock_irq
    when != read_unlock_irqrestore
    when != write_unlock_irqrestore
    when != spin_unlock_irq
    when != spin_unlock_irqrestore
    when != sti
    when != local_irq_enable
  GFP_KERNEL@p1
 ... when any
}

@gstatfns@
identifier gfp.fn;
position gfp.p;
@@

static fn@p(...) { ... }

@safe@
position p1;
identifier virtual.alloc;
@@

alloc@p1(...,GFP_ATOMIC,...)

@fns exists@
identifier virtual.alloc, fn != {panic};
position p;
position p1 != safe.p1;
@@

fn@p(...) {
... when != mutex_unlock
    when != spin_unlock
    when != read_unlock
    when != write_unlock
    when != up
    when != local_irq_restore
    when != restore_flags
    when != read_unlock_irq
    when != write_unlock_irq
    when != read_unlock_irqrestore
    when != write_unlock_irqrestore
    when != spin_unlock_irq
    when != spin_unlock_irqrestore
    when != sti
    when != local_irq_enable
  alloc@p1(...)
 ... when any
}

@statfns@
identifier fns.fn;
position fns.p;
@@

static fn@p(...) { ... }

@script:python depends on statfns@
fn << fns.fn;
alloc << virtual.alloc;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << fns.p;
@@

str = "echo call stat %s to %s in %s && " % (fn,alloc,p[0].file)
print str,
output_static("schedule",fn,tmp,fl,version," -D after_start",p[0].file)

@script:python depends on !statfns@
fn << fns.fn;
alloc << virtual.alloc;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << fns.p;
@@

str = "echo call ext %s to %s in %s && " % (fn,alloc,p[0].file)
print str,
output_external("schedule",fn,tmp,fl,version," -D after_start")





@script:python depends on gstatfns@
fn << gfp.fn;
alloc << virtual.alloc;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << gfp.p;
@@

str = "echo gfp stat %s to %s in %s && " % (fn,alloc,p[0].file)
print str,
output_static("schedule",fn,tmp,fl,version," -D after_start",p[0].file)

@script:python depends on !gstatfns@
fn << gfp.fn;
alloc << virtual.alloc;
fl << virtual.file;
version << virtual.version;
tmp << virtual.tmp;
p << gfp.p;
@@

str = "echo gfp ext %s to %s in %s && " % (fn,alloc,p[0].file)
print str,
output_external("schedule",fn,tmp,fl,version," -D after_start")
