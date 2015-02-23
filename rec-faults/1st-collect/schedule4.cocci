virtual after_start

@initialize:ocaml@

let tbl = Hashtbl.create(101)
let warnings = Hashtbl.create(101)

let inc k =
    if not (k = "GFP_KERNEL") then begin
    let cell = try Hashtbl.find warnings k
    	with Not_found ->
	     let cell = ref 0 in
	     Hashtbl.add warnings k cell;
	     cell in
    cell := !cell + 1 end

let add_if_not_present from f file file2 =
match Str.split (Str.regexp "/arch/") file2 with
[_;_] -> ()
|_ ->
 begin
inc from;
try let _ = Hashtbl.find tbl (f,file) in ()
with Not_found ->
   Hashtbl.add tbl (f,file) file;
   Printf.printf "# from %s to %s in %s\n" from f file2;
   let it = new iteration() in
   (match file with (* checks for static *)
     Some fl ->
      Printf.printf "-D fn=%s -D defining_file=%s\n" f fl;
      it#set_files [fl]
   | None -> (* checks for external *)
     Printf.printf "-D fn=%s -D external\n" f);
     it#add_virtual_rule After_start;
     it#add_virtual_identifier Alloc f;
     it#register()
 end

@finalize:ocaml@

let l = Hashtbl.fold (fun k v rest -> (!v,k) :: rest) warnings [] in
let l = List.rev (List.sort compare l) in
let rec loop n = function
  [] -> ()
| (v,k) :: xs ->
  if n > 0 then (Printf.printf "# %s: %d\n" k v; loop (n-1) xs) in
loop 20 l

@gfp depends on !after_start exists@
identifier fn != {panic,change_page_attr,__change_page_attr,free_irq,mm_release,request_irq,ioremap,__ioremap,show_stack,dump_stack,dump_page,flush_tlb_range,free_block,slab_alloc,__slab_alloc,kmem_cache_alloc};
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
identifier virtual.alloc, fn != {panic,change_page_attr,__change_page_attr,free_irq,mm_release,request_irq,ioremap,__ioremap,show_stack,dump_stack,dump_page,flush_tlb_range,free_block,slab_alloc,__slab_alloc,kmem_cache_alloc};
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
