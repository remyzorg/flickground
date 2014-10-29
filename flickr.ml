
type error = Malformed_json of string
exception Error of error

let malformed s = raise (Error (Malformed_json s))


let rest = "https://api.flickr.com/services/rest/"

let apikey = "b551afe7603cf01eac70d54262cd07df"

open Lwt


module Net = struct
  let get_string url =
    Ocsigen_http_client.get_url url >>= begin function
    | {Ocsigen_http_frame.frame_content = Some v } ->
      Ocsigen_stream.string_of_stream 100000 (Ocsigen_stream.get v)
    | _ -> return "" end |> Lwt_main.run


  let get_bin url =
    Ocsigen_http_client.get_url url >>= begin function
    | {Ocsigen_http_frame.frame_content = Some v } ->
      Ocsigen_stream.string_of_stream 100000000 (Ocsigen_stream.get v)
    | _ -> return "" end |> Lwt_main.run


end

let mk_rq meth others =
  let req = rest ^ "?api_key=" ^ apikey ^ "&method=" ^ meth ^ "&format=json" ^ others
  in Format.printf "Request : %s@\n" req;
  Net.get_string req


module Method = struct
  let flickr = "flickr."

  module People = struct
    let string  m = flickr ^ "people." ^ m
    let getPhotos user_id =
      mk_rq (string "getPhotos") ("&user_id=" ^ user_id ^ "&extra=url_o")
  end

  module Photos = struct
    let string m = flickr ^ "photos." ^ m
    let getSizes photo_id =
      mk_rq (string "getSizes") ("&photo_id=" ^ photo_id)
  end

end


module Json = struct
  open Yojson
  open Yojson.Basic.Util

  let json_header = "jsonFlickrApi("

  let pretty = Basic.pretty_to_string

  let extract_json data =
    String.(sub data (length json_header) (length data - 1 - length json_header))
        |> Basic.from_string

  let extract_photos json =
    [json]
        |> filter_member "photos"
        |> filter_member "photo"
        |> flatten
        |> filter_member "id"
        |> filter_string


  let extract_url json =
    [json]
        |> filter_member "sizes"
        |> filter_member "size"
        |> flatten
        |> List.filter (fun x -> [x]
          |> filter_member "label"
          |> filter_string
          |> List.mem "Original")
        |> filter_member "source"
        |> filter_string



end
