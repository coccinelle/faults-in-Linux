@locked@
position p,p1;
expression E1;
@@

(
spin_lock_bh@p1
|
read_lock_bh@p1
|
write_lock_bh@p1
) (E1@p,...);

// this would be nicer if there where a
// if (E != NULL || ...) { <+... when forall E ...+> } else S
// but cocci doesn't parse the nested when
@ends_in_lock exists@
expression locked.E1;
identifier lock;
position locked.p,p1,p2;
identifier f;
@@

f (...) { <+...
lock@p1 (E1@p,...);
... when != E1
return@p2 ...;
...+> }

@ends_in_unlock exists@
expression locked.E1;
identifier unlock;
position p!=locked.p;
identifier ends_in_lock.f;
@@

f (...) { <+...
unlock (E1@p,...);
... when != E1
return ...;
...+> }

@balanced depends on ends_in_lock && ends_in_unlock exists@
position locked.p, p1 != locked.p1;
identifier ends_in_lock.lock,ends_in_unlock.unlock,ends_in_lock.f;
expression E,locked.E1;
@@

f (...) { <+...
if (E) {
 <+... when != E1
 lock(E1@p,...)
 ...+>
}
... when != E1
    when forall
if (E) {
 <+... when != E1
 unlock@p1(E1,...)
 ...+>
}
...+> }

@script:python depends on ends_in_lock && ends_in_unlock && !balanced@
p << locked.p;
p2 << ends_in_lock.p2;
unlock << ends_in_unlock.unlock;
lock << ends_in_lock.lock;
@@

cocci.print_main(lock,p)
cocci.print_secs(unlock,p2)
