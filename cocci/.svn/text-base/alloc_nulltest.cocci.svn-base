//
// Missing NULL test
//
// Keywords: kmalloc, kzalloc, kcalloc
// Version min: < 12 kmalloc
// Version min: < 12 kcalloc
// Version min:   14 kzalloc
// Version max: *
//

virtual org

@ r depends on org using "alloc.iso" @

type T;
expression *x;
identifier f;
constant char *C;
position p1,p2;
@@

x@p1 = (T)an_allocator(...);
... when != x == NULL
    when != x != NULL
    when != (x || ...)
(
kfree(x)
|
f(...,C,...,x,...)
|
f@p2(...,x,...)
|
x->f@p2
)

@script:python@
x << r.x;
p1 << r.p1;
p2 << r.p2;
@@

msg = "%s" % (x)
coccilib.org.print_safe_todo(p1[0],msg)
coccilib.org.print_link(p2[0])
cocci.include_match(False)