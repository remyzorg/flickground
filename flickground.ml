
open Format

open Lwt

    (* launch both requests in parallel *)


open Flickr



let user = "48404998@N08"

let config_dir = Unix.((getpwnam (getlogin ())).pw_dir) ^
  "/.config/flickground"

let backgrounds_dir = config_dir ^ "/backgrounds"


let () =
  if not (Sys.file_exists config_dir) ||
    not (Sys.is_directory config_dir) then
    Unix.mkdir config_dir 0o700;
  if not (Sys.file_exists backgrounds_dir) ||
    not (Sys.is_directory backgrounds_dir) then
    Unix.mkdir backgrounds_dir 0o700



(* let filename = backgrounds_dir ^ "/" ^ ("test" ^ ".jpg") *)

(* let () = *)
(*   let c = open_out filename in *)
(*   fprintf (formatter_of_out_channel c) "%s" "JAMBON"; *)
(*   close_out c *)



let photo_id =
  let open Yojson in
  let request = Flickr.Method.People.getPhotos user in
  let json = Json.extract_json request in
  (* json |> Json.pretty |> printf "%s@\n"; *)
  (* json |> Json.extract_photos |> List.iter (printf "%s@\n"); *)
  let result = json |> Json.extract_photos  in
  let n = Random.self_init (); Random.int (List.length result) in
  let photo_id = List.nth result n in
  printf "Number %d %s@\n" n photo_id;
  photo_id


let filename =
  let filename = backgrounds_dir ^ "/" ^ (photo_id ^ ".jpg") in
  if not (Sys.file_exists filename) then
    let photo_url_data = Flickr.Method.Photos.getSizes photo_id in
    let photo_url = Json.(extract_url (extract_json photo_url_data)) in
    List.iter (printf "%s@\n") photo_url;
    let result = Net.get_bin (List.hd photo_url) in
    let outc = open_out filename in
    fprintf (formatter_of_out_channel outc) "%s" result;
    close_out outc;
  else printf "File exists !";
  filename





let () =
  let code = Sys.command ("feh --bg-fill " ^ filename) in
  ()

















  (* List.iter (fun x -> printf "Photo : %s@\n" (Json.pretty x)) photo_url; *)
  (* List.iter (fun x -> printf "%s@\n" (Json.pretty x)) (Json.extract_photos json); *)
