
open Format

open Lwt

    (* launch both requests in parallel *)


open Flickr




let user = "48404998@N08"


let () =
  let open Yojson in
  let request = Flickr.get_photos user in
  let json = Json.extract_json request in

  (* json |> Json.pretty |> printf "%s@\n" *)

  json |> Json.extract_photos |> List.iter (printf "%s@\n")
