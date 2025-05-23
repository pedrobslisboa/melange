(* Copyright (C) 2020- Hongbo Zhang, Authors of ReScript
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

let names_from_construct_pattern
    (pat : Patterns.Head.desc Typedtree.pattern_data) =
  let is_nullary_variant (x : Types.constructor_arguments) =
    match x with Types.Cstr_tuple [] -> true | _ -> false
  in
  let names_from_type_variant (cstrs : Types.constructor_declaration list) =
    let get_cstr_name (cstr: Types.constructor_declaration) =
      Lam_constant_convert.modifier ~name:(Ident.name cstr.cd_id) cstr.cd_attributes
    in
    let get_block (cstr: Types.constructor_declaration) =
      { Lambda.cstr_name = get_cstr_name cstr
      ; tag_name = Lam_variant_tag.process_tag_name cstr.cd_attributes
      }
    in
    let consts, blocks =
      List.fold_left
        ~init:([], []) cstrs
        ~f:(fun (consts, blocks)
                (cstr : Types.constructor_declaration) ->
            if is_nullary_variant cstr.cd_args then
              (get_cstr_name cstr :: consts , blocks)
            else
              (consts , get_block cstr :: blocks))
    in
    {
      Lambda.consts = Array.reverse_of_list consts;
      blocks = Array.reverse_of_list blocks;
    }
  in
  let rec resolve_path n path =
    match Env.find_type path pat.pat_env with
    | exception Not_found -> None
    | { type_kind = Type_variant (cstrs, _repr); _ } ->
        Some (names_from_type_variant cstrs)
    | { type_kind =
#if OCAML_VERSION >= (5,2,0)
          Type_abstract _
#else
          Type_abstract
#endif
      ; type_manifest = Some t
      ; _ } -> (
        match Types.get_desc (Ctype.unalias t) with
        | Tconstr (pathn, _, _) ->
            (* Format.eprintf "XXX path%d:%s path%d:%s@." n (Path.name path) (n+1) (Path.name pathn); *)
            resolve_path (n + 1) pathn
        | _ -> None)
    | { type_kind =
#if OCAML_VERSION >= (5,2,0)
          Type_abstract _
#else
          Type_abstract
#endif
      ; type_manifest = None
      ; _ } -> None
    | { type_kind = Type_record _ | Type_open (* Exceptions *); _ } -> None
  in

  match Types.get_desc pat.pat_type with
  | Tconstr (path, _, _) -> resolve_path 0 path
  | _ -> assert false
