let home = "/fast_scratch/linuxes"

let andand i =
  let lines = ref [] in
  let rec loop _ =
    let l = input_line i in
    (match Str.split (Str.regexp " && ") l with
      [a;b] -> lines := b :: !lines
    | [b] -> lines := b :: !lines
    | _ -> failwith ("bad line: "^l));
    loop() in
  try loop() with End_of_file -> List.rev !lines

type ext = Stat of string * string | Ext of string

let getargs l =
  match Str.split (Str.regexp "alloc=") l with
    [a;b] ->
      (match Str.split (Str.regexp "[= ]") b with
	fn::_ ->
	  (match Str.split (Str.regexp "-dir ") l with
	    [a;b] ->
	      (match Str.split (Str.regexp " ") b with
		dir::_ -> Ext fn
	      |	_ -> failwith "bad dir")
	  | [a] ->
	      (match Str.split (Str.regexp home) l with
		[a;b] ->
		  (match Str.split (Str.regexp " ") b with
		    file::_ ->
		      let file = home^file in
		      Stat (fn,file)
		  | _ -> failwith ("no file in "^l))
	      |	_ -> failwith ("no file in "^l))
	  | _ -> failwith "bad dir")
      | _ -> failwith "bad fn")
  | _ -> failwith ("bad line: "^l)

let printer = function
    Stat(fn,file) -> Printf.printf "-D fn=%s -D defining_file=%s\n" fn file
  | Ext fn -> Printf.printf "-D fn=%s -D external\n" fn

let _ =
  let args = List.tl(Array.to_list Sys.argv) in
  let file = List.hd args in
  let i = open_in file in
  let lines = andand i in
  let data = List.rev_map getargs lines in
  List.iter printer data
