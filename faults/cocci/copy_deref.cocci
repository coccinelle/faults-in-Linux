// -no_includes -include_headers

@c@
expression E;
position p;
type T;
@@

(
copy_from_user@p((T)E,...)
|
memcpy_fromfs@p((T)E,...)
)

@r@
expression subE<=c.E;
expression c.E;
position c.p;
statement S1,S2;
expression E1,E2;
position p2;
identifier f,g;
type T;
@@

(
copy_from_user@p((T)E,...)
|
memcpy_fromfs@p((T)E,...)
)
... when != E->f = E1
(
 subE = E2
|
 &subE
|
 *(E@p2->f) // bad use
|
 E@p2->f->g // bad use
)

@script:python@
p << c.p;
p2 << r.p2;
@@

cocci.print_main("copy from user",p)
cocci.print_secs("use",p2)

@ok2@
expression c.E;
identifier f;
position pok;
@@

sizeof(E@pok.f)

@s@
expression subE<=c.E;
expression c.E;
position c.p;
statement S1,S2;
expression E1,E2;
position p2!=ok2.pok;
identifier f,g;
type T;
@@

(
copy_from_user@p((T)&E,...)
|
memcpy_fromfs@p((T)&E,...)
)
... when != E.f = E1
(
 subE = E2
|
 &subE
|
 *(E@p2.f) // bad use
|
 E@p2.f->g // bad use
)

@script:python@
p << c.p;
p2 << s.p2;
@@

cocci.print_main("copy from user",p)
cocci.print_secs("use",p2)