(* flickground.ml *)


open Format
open Set_background
open Common

let config_dir = Unix.((getpwnam (getlogin ())).pw_dir) ^
  "/.config/flickground"

let config_file = config_dir ^ "/" ^ "flickgroundrc"

let backgrounds_dir = config_dir ^ "/backgrounds"

let () =
  if not (Sys.file_exists config_dir) ||
    not (Sys.is_directory config_dir) then
    Unix.mkdir config_dir 0o700;
  if not (Sys.file_exists backgrounds_dir) ||
    not (Sys.is_directory backgrounds_dir) then
    Unix.mkdir backgrounds_dir 0o700


let users = ref []
let search = ref ""
let parse_only = ref false
let debug = ref false

let msg = "usage: flickground [options] [users]"
let set_users u = users := if List.mem u !users then !users else u :: !users
let spec = [
  "--debug", Arg.Set debug, "  Set debug on";
  "--search", Arg.Set_string search, "  Search by username";
  "--parse-only", Arg.Set parse_only, "  Stop after parsing config file";
]


let parse_config () =
  if Sys.file_exists config_file then
    let c = open_in config_file in
    let table = ref [] in
    let rec step () =
      match input_line c with
      | exception e -> close_in c
      | s -> table := s :: !table;
        step ()
    in
    step ();
    let lines = List.rev !table in
    let confs = ref [] in
    ()
    (* List.iter (fun x -> split) lines *)


let () =
  List.iter (printf "%s@\n") (splitc '|' "abc|de|fgh")


let () = Arg.parse spec set_users msg

let () =
  if !debug then List.iter print_endline !users;
  if !parse_only then exit 0;
  let user = List.hd !users in
  Set_background.run user config_dir backgrounds_dir
