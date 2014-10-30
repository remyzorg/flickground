(* flickground.ml *)


open Format
open Set_background
open Common
module Str = Re_str

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
    let table =
      let rec step l =
        match input_line c with
        | exception e -> close_in c; l
        | s -> step (s :: l)
      in
      List.rev (step []);
    in
    table
      |> List.map (split ":")
      |> List.map (function
        | n :: v :: [] -> n, v
        | _ -> "", ""
      )
      |> List.iter (function
        | "users", v -> List.iter set_users (split " " v)
        | _ -> ()

      )




let () =
  Arg.parse spec set_users msg;
  parse_config ()



let () =
  if !debug then List.iter print_endline !users;
  if !parse_only then exit 0;
  let user = List.hd !users in
  Set_background.run user config_dir backgrounds_dir
