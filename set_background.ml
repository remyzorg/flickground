

open Format
open Flickr


let run user config_dir backgrounds_dir =

  let photo_id =
    let open Yojson in
    let request = Flickr.Method.People.getPhotos user in
    let json = Json.extract_json request in
    let result = json |> Json.extract_photos  in
    let n = Random.self_init (); Random.int (List.length result) in
    let photo_id = List.nth result n in
    printf "Number %d %s@\n" n photo_id;
    photo_id
  in

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
  in

  let _ = Sys.command ("feh --bg-fill " ^ filename) in ()
