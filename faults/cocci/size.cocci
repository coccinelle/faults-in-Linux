@r@
type T;
T *x;
position p;
@@

x@p = <+...sizeof(T)...+>

@s@
expression x;
position p;
@@

x@p = <+...sizeof(*x)...+>

@bad@
position p!={r.p,s.p};
type T, T1, T2;
T1 *x;
T2 **y;
typedef u8;
{void *, char *, unsigned char *, u8*} a;
{struct device,struct net_device} dev;
@@

(
dev.priv = ...
|
y = \(kmalloc\|kzalloc\)(<+...sizeof(T)...+>,...)
|
a = \(kmalloc\|kzalloc\)(<+...sizeof(T)...+>,...)
|
x@p = \(kmalloc\|kzalloc\)(<+...sizeof(T)...+>,...)
)

@script:python@
p << bad.p;
@@

cocci.print_main("alloc",p)
