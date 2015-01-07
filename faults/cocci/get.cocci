// -no_includes -include_headers

@c@
expression E;
expression o;
position p;
position p3;
@@

(
get_user@p(E,o)
|
E=get_user@p(o)
|
get_user@p3(o)
)

@r@
expression subE<=c.E;
expression c.E;
expression o;
position c.p;
statement S1,S2;
expression E2;
position p2;
@@

(
get_user@p(E,o)
|
E=get_user@p(o)
)
...
(
 if (((E2 > E) && ...) || ...) S1 else S2
|
 if (((E2 >= E) && ...) || ...) S1 else S2
|
 subE = E2
|
 &subE
|
 E2 < E@p2 // bad use
|
 E2 <= E@p2 // bad use
|
 E2[(<+...E@p2...+>)] // bad use
)

@script:python@
p << c.p;
p2 << r.p2;
@@

cocci.print_main("get user",p)
cocci.print_secs("use",p2)

@s@
position c.p3;
expression E2;
expression o;
@@

(
 E2 < get_user@p3(o) // bad use
|
 E2 <= get_user@p3(o) // bad use
|
 E2[(<+...get_user@p3(o)...+>)] // bad use
)

@script:python depends on s@
p << c.p3;
@@

cocci.print_main("get user",p)
