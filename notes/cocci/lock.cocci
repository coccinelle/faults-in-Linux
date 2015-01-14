@r@
expression E;
position p;
@@

(
mutex_lock@p
|
mutex_trylock@p
|
spin_lock@p
|
spin_trylock@p
|
read_lock@p
|
read_trylock@p
|
write_lock@p
|
write_trylock@p
)
 (...)

@script:python@
p << r.p;
@@

cocci.print_main("lock",p)
