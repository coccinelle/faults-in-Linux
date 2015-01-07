// this deals with cases where the array size is an identifier or a more
// complex expression

@initialize:python@

def check_and_print(t,vl,nm,mx,p):
  vl = "%s" % vl
  try:
    ev = eval(vl)
    if (ev > mx):
      cocci.print_main("%s %d" % (t,ev),p)
  except:
    cocci.print_main("%s %s" % (t,nm),p)

@r exists@
identifier f;
identifier i,i1;
type T;
position p,p1;
constant c;
expression e;
@@

f(...) { <+...
(
  T i@p[i1@p1];
|
  T i[c];
|
  T i[sizeof(...)];
|
  T i@p[e@p1];
)
 ...+>
}

// ---------------------------------------------------------------------
// identifier case

@cst@
identifier r.i1;
expression e;
@@

#define i1 e

// identifier, but no information about the size
@script:python depends on !cst@
p << r.p1;
i << r.i1;
t << r.T;
@@

cocci.print_main("%s %s" % (t,i),p)
cocci.include_match(False)

@d depends on cst@
identifier r.i1;
position r.p,p_char,p_str,p_other;
type T;
identifier i,I;
typedef u8;
typedef u_char;
@@

(
unsigned char i@p[i1@p_char];
|
char i@p[i1@p_char];
|
u_char i@p[i1@p_char];
|
u8 i@p[i1@p_char];
|
struct I i@p[i1@p_str];
|
T i@p[i1@p_other];
)

@script:python@
c << cst.e;
p << d.p_char;
i1 << r.i1;
t << r.T;
@@

check_and_print(t,c,i1,1024,p)

@script:python@
c << cst.e;
p << d.p_str;
i1 << r.i1;
t << r.T;
@@

check_and_print(t,c,i1,128,p)

@script:python@
c << cst.e;
p << d.p_other;
i1 << r.i1;
t << r.T;
@@

check_and_print(t,c,i1,256,p)

// ---------------------------------------------------------------------
// expression case

@exp@
expression r.e;
position r.p,p_char,p_str,p_other;
type T;
identifier i,I;
@@

(
unsigned char i@p[e@p_char];
|
char i@p[e@p_char];
|
u_char i@p[e@p_char];
|
u8 i@p[e@p_char];
|
struct I i@p[e@p_str];
|
T i@p[e@p_other];
)

@script:python@
p << exp.p_char;
c << r.e;
t << r.T;
@@

check_and_print(t,c,c,1024,p)

@script:python@
p << exp.p_str;
c << r.e;
t << r.T;
@@

check_and_print(t,c,c,128,p)

@script:python@
p << exp.p_other;
c << r.e;
t << r.T;
@@

check_and_print(t,c,c,256,p)
