


let splitc sep s =
  let open Buffer in
  let bacc = create (String.length s) in
  let l = ref [] in
  let sepc = ref 0 in
  for i = 0 to String.length s - 1 do
    if s.[i] = sep.[!sepc] then begin
      (* add_char bacc s.[i]; *)
      incr sepc;
      if !sepc = String.length sep then begin
        l := (contents bacc) :: !l;
        clear bacc;
        sepc := 0;
      end
    end else add_char bacc s.[i]
  done;
  l := (contents bacc) :: !l;
  List.rev !l


(* let split sep s = *)
(*   let open Buffer in *)
(*   let bacc = create (String.length s) in *)
(*   let l = ref [] in *)
(*   let sepc = ref 0 in *)
(*   for i = 0 to String.length s - 1 do *)
(*     if s.[i] = sep.[!sepc] then begin *)
(*       (\* add_char bacc s.[i]; *\) *)
(*       incr sepc; *)
(*       if !sepc = String.length sep then begin *)
(*         l := (contents bacc) :: !l; *)
(*         clear bacc; *)
(*         sepc := 0; *)
(*       end *)
(*     end else add_char bacc s.[i] *)
(*   done; *)
(*   l := (contents bacc) :: !l; *)
(*   List.rev !l *)
