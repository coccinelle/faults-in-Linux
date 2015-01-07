//
// kmalloc 7
//
// Keywords: kmalloc, kzalloc, kcalloc
// Version min: < 12 kmalloc
// Version min: < 12 kcalloc
// Version min:   14 kzalloc
// Version max: *
//

virtual org

@r exists@
type T;
local idexpression x;
statement S;
expression E;
identifier f,l;
position p1,p2,p3;
expression *ptr != NULL;
@@

(
if ((x@p1 = (T)an_allocator(...)) == NULL) S
|
x@p1 = (T)an_allocator(...);
...
if (x == NULL) S
)
<... when != x
     when != if (...) { <+...x...+> }
(
goto@p3 l;
|
x->f = E
)
...>
(
 return \(0\|<+...x...+>\|ptr\);
|
 return@p2 ...;
)

@script:python@
x << r.x;
p1 << r.p1;
p2 << r.p2;
@@

coccilib.org.print_todo(p1[0], x)
for p in p2:
	coccilib.org.print_link(p)
cocci.include_match(False)