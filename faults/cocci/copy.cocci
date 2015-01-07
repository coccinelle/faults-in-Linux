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

@ok1@
expression c.E;
identifier f;
position pok;
@@

sizeof(E@pok->f)

@r@
expression subE<=c.E;
expression c.E;
position c.p;
statement S1,S2;
expression E2;
position p2!=ok1.pok;
identifier f;
type T;
@@

(
copy_from_user@p((T)E,...)
|
memcpy_fromfs@p((T)E,...)
)
...
(
 if (((E2 > E->f) && ...) || ...) S1 else S2
|
 if (((E2 >= E->f) && ...) || ...) S1 else S2
|
 subE = E2
|
 &subE
|
 E2 < E@p2->f // bad use
|
 E2 <= E@p2->f // bad use
|
 E2[(<+...E@p2->f...+>)] // bad use
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
expression E2;
position p2!=ok2.pok;
identifier f;
type T;
@@

(
copy_from_user@p((T)&E,...)
|
memcpy_fromfs@p((T)&E,...)
)
...
(
 if (((E2 > E.f) && ...) || ...) S1 else S2
|
 if (((E2 >= E.f) && ...) || ...) S1 else S2
|
 subE = E2
|
 &subE
|
 E2 < E@p2.f // bad use
|
 E2 <= E@p2.f // bad use
|
 E2[(<+...E@p2.f...+>)] // bad use
)

@script:python@
p << c.p;
p2 << s.p2;
@@

cocci.print_main("copy from user",p)
cocci.print_secs("use",p2)