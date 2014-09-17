//
// From: Documentation/CodingStyle (v14-v31)
//
//                 Chapter 14: Allocating memory
//
// The kernel provides the following general purpose memory allocators:
// kmalloc(), kzalloc(), kcalloc(), and vmalloc().  Please refer to the API
// documentation for further information about them.
//
// The preferred form for passing a size of a struct is the following:
//
//         p = kmalloc(sizeof(*p), ...);
//
// The alternative form where struct name is spelled out hurts readability and
// introduces an opportunity for a bug when the pointer variable type is changed
// but the corresponding sizeof that is passed to a memory allocator is not.
//
// Casting the return value which is a void pointer is redundant. The conversion
// from void pointer to any other pointer type is guaranteed by the C programming
// language.
//
// Keywords: kmalloc, kzalloc, kcalloc
// Version min: < 12 kmalloc
// Version min: < 12 kcalloc
// Version min:   14 kzalloc
// Version max: *
//

virtual org

@ r depends on org disable sizeof_type_expr, linux_allocators@
type T,T1;
T *x;
expression n;
position p;
@@

(
x@p = (T1)an_allocator_size1(<+... sizeof(T) ...+>, ...)
|
x@p = (T1)a_block_allocator(n, <+... sizeof(T) ...+>, ...)
)

@script:python@
p << r.p;
x << r.x;
xtype << r.T;
@@

msg = "var: %s type: %s " % (x,xtype)
coccilib.org.print_safe_todo(p[0],msg)
cocci.include_match(False)