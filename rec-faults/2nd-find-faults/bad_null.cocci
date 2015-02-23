// use argument -D fn=xxx for the name of the null returning function of
// interest
// -no_includes -include_headers

virtual external

@call_bad@
identifier virtual.fn;
position p1;
expression E,E1,E2;
statement S;
@@

(
 for(E=fn@p1(...);E!=NULL;...) S
|
 for(...;E!=NULL;E=fn@p1(...)) S
|
 for(;E!=NULL;E=fn@p1(...)) S
|
 (E1 = fn@p1(...)) == NULL
|
 (E1 = fn@p1(...)) != NULL
|
 (E1 = fn@p1(...)) == 0
|
 (E1 = fn@p1(...)) != 0
|
 (E2 = E1 = fn@p1(...)) == NULL
|
 (E2 = E1 = fn@p1(...)) != NULL
|
 (E2 = E1 = fn@p1(...)) == 0
|
 (E2 = E1 = fn@p1(...)) != 0
)

@call@
identifier virtual.fn;
position p1,pf!=call_bad.p1;
expression E;
@@

 E@p1 = fn@pf(...)

@script:python depends on !external@
p1 << call.p1;
E << call.E;
defining_file << virtual.defining_file;
@@

defining_file = "%s" % defining_file # convert a cocci string to a python one
if (not(p1[0].file == defining_file)):
 cocci.include_match(False)

// --------------------------------------------------------------------
// safe references

@pr1 expression@
expression call.E;
identifier f;
position a1;
@@

 (E != NULL && ...) ? <+...\(f@a1(...,E,...)\|E->f@a1\)...+> : ...

@pr2 expression@
expression call.E;
identifier f;
position a2;
@@

(
  (E != NULL) && ... && <+...\(f@a2(...,E,...)\|E->f@a2\)...+>
|
  (E == NULL) || ... || <+...\(f@a2(...,E,...)\|E->f@a2\)...+>
|
  sizeof(<+...E->f@a2...+>)
)

// --------------------------------------------------------------------

@r disable unlikely exists@
expression subE<=call.E,E1;
expression call.E;
position call.p1,p2;
identifier f,fld;
identifier virtual.fn;
position p != {pr1.a1,pr2.a2};
type T;
@@

E@p1 = fn(...)
... when != subE = E1
    when != &subE
    when != E == (T)NULL
    when != E != (T)NULL
    when != E == NULL
    when != E != NULL
    when != E == 0
    when != E != 0
    when != unlikely(E)
    when != likely(E)
E@p2->fld@p

@script:python@
fn << virtual.fn;
p1 << call.p1;
p2 << r.p2;
@@

cocci.print_main(fn,p1)
cocci.print_secs("ref",p2)
