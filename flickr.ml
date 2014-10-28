
type error = Malformed_json of string
exception Error of error

let malformed s = raise (Error (Malformed_json s))


let rest = "https://api.flickr.com/services/rest/"

let apikey = "b551afe7603cf01eac70d54262cd07df"

open Lwt


module Net = struct
  let get url =
    Ocsigen_http_client.get_url url >>= begin function
    | {Ocsigen_http_frame.frame_content = Some v } ->
      Ocsigen_stream.string_of_stream 1000000 (Ocsigen_stream.get v)
    | _ -> return "" end |> Lwt_main.run

end



module Method = struct
  module People = struct
    let getPhotos = "flickr.people.getPhotos"
  end
end



let mk_rq meth others =
  let req = rest ^ "?api_key=" ^ apikey ^ "&method=" ^ meth ^ "&format=json" ^ others
  in Format.printf "Request : %s@\n" req;
  Net.get req


let get_photos user =
  mk_rq Method.People.getPhotos ("&user_id=" ^ user)




module Json = struct
  open Yojson

  let json_header = "jsonFlickrApi("

  let pretty = Safe.pretty_to_string

  let extract_json data =
    String.(sub data (length json_header) (length data - 1 - length json_header))
        |> Safe.from_string

  let extract_photos = function
    | `Assoc l ->
      begin l
          |> List.assoc "photos"
          |> begin function `Assoc photos -> photos | _ -> malformed "json" end
          |> List.assoc "photo"
          |> begin function `List l -> l | _ -> malformed "json" end
          |> List.map (function
            | `Assoc photo -> begin photo
                |> List.assoc "id"
                |> begin function `String s -> s | _ -> malformed "json" end
              end
            | _ -> malformed "json"
          ) end
    | _ -> malformed "json"

end
