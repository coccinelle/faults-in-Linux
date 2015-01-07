@r exists@
identifier f;
identifier i,i1;
constant c;
type T;
position p;
@@

f(...) { <+...
(
  T i[i1];
|
  T i[sizeof(...)];
|
  T i@p[c];
)
 ...+>
}

@s@
constant c_char, c_str, c_other;
position r.p,p1;
type T;
identifier i,I;
typedef u8;
@@

(
unsigned char i@p[c_char@p1];
|
char i@p[c_char@p1];
|
u_char i@p[c_char@p1];
|
u8 i@p[c_char@p1];
|
struct I i@p[c_str@p1];
|
T i@p[c_other@p1];
)

@script:python@
c << s.c_char;
p << s.p1;
@@

c = "%s" % c
try:
  if (int(c) > 1024):
    cocci.print_main(c,p)
except ValueError:
    i = 0

@script:python@
c << s.c_str;
p << s.p1;
@@

c = "%s" % c
try:
  if (int(c) > 128):
    cocci.print_main(c,p)
except ValueError:
    i = 0

@script:python@
c << s.c_other;
p << s.p1;
@@

c = "%s" % c
try:
  if (int(c) > 256):
    cocci.print_main(c,p)
except ValueError:
    i = 0

