open Common

(* ---------------------------------------------------------------------- *)
(* find the starting and ending line number of each function *)

let count_lines version short_name = function
    Ast_c.Definition (defbis, ii) ->
      (match ii with
	iifunc1::iifunc2::i1::i2::ifakestart::isto ->
	  let start = Ast_c.line_of_info i1 in
	  let finish = Ast_c.line_of_info i2 in
	  let name = Ast_c.str_of_name defbis.Ast_c.f_name in
	  Printf.printf "version %s file %s function %s start %d finish %d\n"
	    version short_name name start finish (* add to database *)
      |	_ -> failwith "bad function")
  | _ -> ()

(* ---------------------------------------------------------------------- *)
(* find the length of each file *)

let files_length version short_name name =
  let lst = Common.process_output_to_list ("sloccount --datadir"^version^" ./"^name) in
  let rec loop = function
      [] -> Printf.fprintf stderr "file %s has no size\n" name
    | l::ls ->
	match Str.split (Str.regexp "[ \t]+") l with
	  "ansic:"::lines::_ ->
	    Printf.printf "version %s file %s size %s\n"
	      version short_name lines (* add to database *)
	| "SLOC"::"total"::"is"::"zero,"::_ ->
	    Printf.fprintf stderr "file %s has no size\n" name
	| _ -> loop ls in
  loop lst

(* ---------------------------------------------------------------------- *)
(* find the module of each file *)

let find_module version short_name =
  let name =
    if Str.string_match (Str.regexp_string "drivers/sound") short_name 0
    then String.concat "" (Str.split (Str.regexp_string "/sound") short_name)
    else short_name in
  let cd = "cd /var/linuxes/linux-2.6.33" in
  let cmd =
    Printf.sprintf
      "~/papers/osdi10/experiments/count_lines/get_maintainer.pl --nogit -f %s --subsystem | grep -v @" name in
  let modules = Common.process_output_to_list (cd ^ " ; " ^ cmd) in
  Printf.printf "version %s file %s module %s\n"
    version name (* add to database *)
    (String.concat "." (List.sort compare modules))

(* ---------------------------------------------------------------------- *)
(* setup *)

let test_type_c infile =
  let (program2, _stat) =  Parse_c.parse_c_and_cpp false infile in
  List.map fst program2

let position_only = ref false
let dir = ref ("" : string)

let options = []

let anonymous str = dir := str

let c_file fl =
  match List.rev (Str.split (Str.regexp_string ".") fl) with
    "c"::_ -> true
  | _ -> false

let _ =
  Config.std_h := "standard.h";
  if !Config.std_h <> ""
  then Parse_c.init_defs_builtins !Config.std_h;
  Flag_parsing_c.verbose_lexing := false;
  Flag_parsing_c.verbose_parsing := false;
  Flag_parsing_c.show_parsing_error := false;
  Flag_cocci.include_options := Flag_cocci.I_NO_INCLUDES;
  Arg.parse options anonymous "";
  let files =
    if c_file !dir then [!dir]
    else Common.cmd_to_list ("find "^ !dir ^" -name \"*.[ch]\"") in
  List.iter
    (function x ->
      let (version,short_name) =
	match Str.split (Str.regexp "/linux-") x with
	  _::rest ->
	    let b = String.concat "/linux-" rest in
	    (match Str.split (Str.regexp "/") b with
	      version::rest -> (version,String.concat "/" rest)
	    | _ -> failwith (Printf.sprintf "bad file %s" b))
	| _ -> failwith (Printf.sprintf "bad file %s" x) in
      List.iter (count_lines version short_name) (test_type_c x);
      files_length version short_name x(*;
      find_module version short_name*))
    files
