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

open Import

module Literals = struct
  let setter_suffix = "#="
  (* let gentype_import = "genType.import" *)

  let infix_ops = [ "|."; setter_suffix; "##" ]
end

type module_bind_name =
  | Phint_name of string (* explicit hint name *)
  | Phint_nothing

type external_module_name = {
  bundle : string;
  module_bind_name : module_bind_name;
}

type arg_type = External_arg_spec.t
(* TODO: information between [arg_type] and [arg_label] are duplicated,
   design a more compact representation so that it is also easy to seralize by
   hand *)

type arg_label = External_arg_spec.Obj_label.t

type external_spec =
  | Js_var of {
      name : string;
      external_module_name : external_module_name option;
      scopes : string list;
    }
  | Js_module_as_var of external_module_name
  | Js_module_as_fn of {
      external_module_name : external_module_name;
      variadic : bool;
    }
  | Js_module_as_class of external_module_name
  | Js_call of {
      name : string;
      external_module_name : external_module_name option;
      variadic : bool;
      scopes : string list;
    }
  | Js_send of {
      name : string;
      variadic : bool;
      self_idx : int;
      new_ : bool;
      scopes : string list;
    }
    (* we know it is a js send, but what will happen if you pass an ocaml object *)
  | Js_new of {
      name : string;
      external_module_name : external_module_name option;
      variadic : bool;
      scopes : string list;
    }
  | Js_set of { name : string; scopes : string list }
  | Js_get of { name : string; scopes : string list }
  | Js_get_index of { scopes : string list }
  | Js_set_index of { scopes : string list }

type return_wrapper =
  | Return_unset
  | Return_identity
  | Return_undefined_to_opt
  | Return_null_to_opt
  | Return_null_undefined_to_opt
  | Return_replaced_with_unit

type params =
  | Params of External_arg_spec.Arg_label.t External_arg_spec.param list
  | Param_number of int

type t =
  | Ffi_mel of params * return_wrapper * external_spec
      (**  [Ffi_mel(args,return,attr) ]
       [return] means return value is unit or not,
        [true] means is [unit] *)
  | Ffi_obj_create of External_arg_spec.Obj_label.t External_arg_spec.param list
  | Ffi_inline_const of Lam_constant.t
  | Ffi_normal
(* When it's normal, it is handled as normal c functional ffi call *)

let to_string (t : t) = Marshal.to_string t []

external from_bytes_unsafe : bytes -> int -> 'a = "caml_input_value_from_bytes"

(* TODO: better error message when version mismatch *)
let from_string =
  (* \132\149\166\190
   0x84 95 A6 BE Intext_magic_small intext.h
   https://github.com/ocaml/merlin/commit/b094c937c3a360eb61054f7652081b88e4f3612f
*)
  let is_mel_primitive s =
    (* TODO(anmonteiro): check this, header_size changed to 16 in 5.1 *)
    String.length s >= 20
    (* Marshal.header_size*) && String.unsafe_get s 0 = '\132'
    && String.unsafe_get s 1 = '\149'
  in
  fun s : t ->
    match is_mel_primitive s with
    | true -> from_bytes_unsafe (Bytes.unsafe_of_string s) 0
    | false -> Ffi_normal

let inline_string_primitive ?op s =
  let lam : Lam_constant.t =
    let unicode =
      match op with
      | Some op -> Utf8_string.is_unicode_string op
      | None -> false
    in
    Const_string { s; unicode }
  in
  Ffi_inline_const lam

(* Let's only do it for string ATM
    for boolean, and ints, a good optimizer should
    do it by default?
    But it may not work after layers of indirection
    e.g, submodule
*)
let inline_bool_primitive b =
  Ffi_inline_const
    (match b with
    | true -> Lam_constant.Const_js_true
    | false -> Lam_constant.Const_js_false)

let inline_int_primitive i =
  (* FIXME: check overflow? *)
  Ffi_inline_const (Const_int { i; comment = None })

let inline_int64_primitive i = Ffi_inline_const (Const_int64 i)
let inline_float_primitive i = Ffi_inline_const (Const_float i)

let ffi_mel =
  let rec ffi_mel_aux acc
      (params : External_arg_spec.Arg_label.t External_arg_spec.param list) =
    match params with
    | { arg_type = Nothing; arg_label = Arg_empty }
        (* same as External_arg_spec.dummy*)
      :: rest ->
        ffi_mel_aux (acc + 1) rest
    | _ :: _ -> -1
    | [] -> acc
  in
  fun (params : External_arg_spec.Arg_label.t External_arg_spec.param list)
      return attr ->
    let n = ffi_mel_aux 0 params in
    if n < 0 then Ffi_mel (Params params, return, attr)
    else Ffi_mel (Param_number n, return, attr)

let ffi_obj_create obj_params = Ffi_obj_create obj_params
