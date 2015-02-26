virtual after_start

@initialize:ocaml@

let tbl = Hashtbl.create(100)

let add_if_not_present from f file file2 =
try let _ = Hashtbl.find tbl (f,file) in ()
with Not_found ->
   Hashtbl.add tbl (f,file) file;
   Printf.printf "# from %s to %s in %s\n" from f file2;
   let it = new iteration() in
   (match file with
     Some fl ->
      Printf.printf "-D fn=%s -D defining_file=%s\n" f fl;
      it#set_files [fl]
   | None -> Printf.printf "-D fn=%s -D external\n" f);
   if from = "GFP_KERNEL" then begin
   it#add_virtual_rule After_start;
   it#add_virtual_identifier Alloc f;
   it#register() end

@gfp depends on !after_start exists@
identifier fn != {panic};
position p,p1;
@@

fn@p(...) {
... when != mutex_unlock(...)
    when != spin_unlock(...)
    when != read_unlock(...)
    when != write_unlock(...)
    when != up(...)
    when != local_irq_restore(...)
    when != restore_flags(...)
    when != read_unlock_irq(...)
    when != write_unlock_irq(...)
    when != read_unlock_irqrestore(...)
    when != write_unlock_irqrestore(...)
    when != spin_unlock_irq(...)
    when != spin_unlock_irqrestore(...)
    when != sti(...)
    when != local_irq_enable(...)
  GFP_KERNEL@p1
 ... when any
}

@gstatfns@
identifier gfp.fn;
position gfp.p;
@@

static fn@p(...) { ... }

@safe@
position p1;
identifier virtual.alloc;
@@

alloc@p1(...,GFP_ATOMIC,...)

@fns exists@
identifier virtual.alloc, fn != {panic};
position p;
position p1 != safe.p1;
@@

fn@p(...) {
... when != mutex_unlock(...)
    when != spin_unlock(...)
    when != read_unlock(...)
    when != write_unlock(...)
    when != up(...)
    when != local_irq_restore(...)
    when != restore_flags(...)
    when != read_unlock_irq(...)
    when != write_unlock_irq(...)
    when != read_unlock_irqrestore(...)
    when != write_unlock_irqrestore(...)
    when != spin_unlock_irq(...)
    when != spin_unlock_irqrestore(...)
    when != sti(...)
    when != local_irq_enable(...)
  alloc@p1(...)
 ... when any
}

@statfns@
identifier fns.fn;
position fns.p;
@@

static fn@p(...) { ... }

@script:ocaml depends on statfns@
fn << fns.fn;
alloc << virtual.alloc;
p << fns.p;
@@

add_if_not_present alloc fn (Some ((List.hd p).file)) ((List.hd p).file)

@script:ocaml depends on !statfns@
fn << fns.fn;
alloc << virtual.alloc;
p << fns.p;
@@

add_if_not_present alloc fn None ((List.hd p).file)


@script:ocaml depends on gstatfns@
fn << gfp.fn;
p << gfp.p;
@@

add_if_not_present "GFP_KERNEL" fn (Some ((List.hd p).file)) ((List.hd p).file)

@script:ocaml depends on !gstatfns@
fn << gfp.fn;
p << gfp.p;
@@

add_if_not_present "GFP_KERNEL" fn None ((List.hd p).file)
