@initialize:python@
import re

m = re.compile("drivers/net/soundmodem/gentbl.c$")
n = re.compile("drivers/net/hamradio/soundmodem/gentbl.c$")

@cstcst@
constant {double,float} c1;
constant c2;
position p0;
@@

(
 c1 +@p0 c2
|
 c1 -@p0 c2
|
 c1 *@p0 c2
|
 c1 /@p0 c2
|
 c2 +@p0 c1
|
 c2 -@p0 c1
|
 c2 *@p0 c1
|
 c2 /@p0 c1
)

@cr@
expression c1;
constant {double,float} c2;
position p1 != cstcst.p0;
position p;
@@

(
 c1 +@p1 c2@p
|
 c1 -@p1 c2@p
|
 c1 *@p1 c2@p
|
 c1 /@p1 c2@p
)

@script:python@
p << cr.p;
c << cr.c2;
@@

if not (m.search (p[0].file)):
 if not (n.search (p[0].file)):
   c = "%s" % c
   msg_safe=c.replace("[","@(").replace("]",")")
   for q in p:
     x = [q]
     cocci.print_main(msg_safe,x)

@cl@
{double,float} c1;
expression c2;
position pl;
position p1 != cstcst.p0;
position p2 != cr.p;
@@

(
 c1@pl +@p1 c2@p2
|
 c1@pl -@p1 c2@p2
|
 c1@pl *@p1 c2@p2
|
 c1@pl /@p1 c2@p2
)

@script:python@
p << cl.pl;
c << cl.c1;
@@

if not (m.search (p[0].file)):
 if not (n.search (p[0].file)):
   c = "%s" % c
   msg_safe=c.replace("[","@(").replace("]",")")
   for q in p:
     x = [q]
     cocci.print_main(msg_safe,x)
