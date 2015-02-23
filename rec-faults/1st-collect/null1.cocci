@@
expression x,y,E;
@@

  x = NULL
  ... when != x = E
      when != &x
      when != false x == NULL
      when != true x != NULL
(
  if (x == NULL || ...) { ... when forall
(
*       return (x);
|
        return y;
)
 ...}
|
* return (x);
)
