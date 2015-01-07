@r exists@
position p1,p2;
expression lock;
@@

(
spin_lock@p1
|
spin_trylock@p1
|
read_lock@p1
|
read_trylock@p1
|
write_lock@p1
|
write_trylock@p1
)
 (lock,...)
... when != lock
GFP_KERNEL@p2

@script:python@
p1 << r.p1;
p2 << r.p2;
@@
cocci.print_main("gfp_kernel",p2)
cocci.print_secs("lock",p1)
