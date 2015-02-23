
@m@
identifier virtual.fn;
type T;
identifier f;
position p;
@@

T fn(...) { <+... f@p(...) ...+> }

@script:python@
f << m.f;
p << m.p;
@@

print "Call: %s at %s" % (f,p[0].line)

