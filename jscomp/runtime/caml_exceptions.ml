(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)

module Map = struct
  type t

  external empty : unit -> t = "" [@@mel.obj]
  external set : t -> string -> int -> unit = "" [@@mel.set_index]

  (* It's the same as `Js.Dict.get` but it doesn't have runtime overhead to
     check if the key exists. *)
  external get_unsafe : t -> string -> int option = ""
  [@@mel.get_index] [@@mel.return nullable]
end

type t = { id : string [@mel.as "MEL_EXN_ID"] }

(**
   Could be exported for better inlining
   It's common that we have
   {[ a = caml_set_oo_id([248,"string",0]) ]}
   This can be inlined as
   {[ a = caml_set_oo_id([248,"string", caml_oo_last_id++]) ]}
*)

let idMap : Map.t = Map.empty ()

let fresh str =
  let id =
    (* we need to assign an ID to exceptions e.g. `Error/1` because functors
       may define exceptions that get instantiated multiple times (with the
       same name). *)
    match Map.get_unsafe idMap str with
    | Some v -> v + 1
    | None -> 1
  in
  Map.set idMap str id;
  id

let create (str : string) : string =
  let id = fresh str in
  str ^ "/" ^ (Obj.magic (id : int) : string)

(**
   This function should never throw
   It could be either customized exception or built in exception
   Note due to that in OCaml extensible variants have the same
   runtime representation as exception, so we can not
   really tell the difference.

   However, if we make a false alarm, classified extensible variant
   as exception, it will be OKAY for nested pattern match

   {[
     match toExn x : exn option with
     | Some _
       -> Js.log "Could be an OCaml exception or an open variant"
     (* If it is an Open variant, it will never pattern match,
        This is Okay, since exception could never have exhaustive pattern match

     *)
     | None -> Js.log "Not an OCaml exception for sure"
   ]}

   However, there is still something wrong, since if user write such code
   {[
     match toExn x with
     | Some _ -> (* assert it is indeed an exception *)
       (* This assertion is wrong, since it could be an open variant *)
     | None -> (* assert it is not an exception *)
   ]}

   This is not a problem in `try .. with` since the logic above is not expressible, see more design in [destruct_exn.md]
*)
let caml_is_extension (type a) (e : a) : bool =
  (not (Js.testAny e)) && Js.typeof (Obj.magic e : t).id = "string"

(** FIXME: remove the trailing `/` *)
let caml_exn_slot_name (x : t) : string = x.id

let caml_exn_slot_id : t -> int =
  [%raw
    {|function(x){
  if (x.MEL_EXN_ID != null) {
    var parts = x.MEL_EXN_ID.split("/");
    if (parts.length > 1) {
      return Number(parts[parts.length - 1])
    } else {
      return -1;
    }
  } else {
    return -1;
  }
}
|}]
