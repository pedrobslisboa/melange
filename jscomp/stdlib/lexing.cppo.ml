(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* The run-time library for lexers generated by camllex *)

type position = {
  pos_fname : string;
  pos_lnum : int;
  pos_bol : int;
  pos_cnum : int;
}

let dummy_pos = {
  pos_fname = "";
  pos_lnum = 0;
  pos_bol = 0;
  pos_cnum = -1;
}

type lexbuf =
  { refill_buff : lexbuf -> unit;
    mutable lex_buffer : bytes;
    mutable lex_buffer_len : int;
    mutable lex_abs_pos : int;
    mutable lex_start_pos : int;
    mutable lex_curr_pos : int;
    mutable lex_last_pos : int;
    mutable lex_last_action : int;
    mutable lex_eof_reached : bool;
    mutable lex_mem : int array;
    mutable lex_start_p : position;
    mutable lex_curr_p : position;
  }

type lex_tables =
  { lex_base: string;
    lex_backtrk: string;
    lex_default: string;
    lex_trans: string;
    lex_check: string;
    lex_base_code : string;
    lex_backtrk_code : string;
    lex_default_code : string;
    lex_trans_code : string;
    lex_check_code : string;
    lex_code: string;}

external c_engine : lex_tables -> int -> lexbuf -> int = "caml_lex_engine"
external c_new_engine : lex_tables -> int -> lexbuf -> int
                      = "caml_new_lex_engine"

let engine tbl state buf =
  let result = c_engine tbl state buf in
  if result >= 0 && buf.lex_curr_p != dummy_pos then begin
    buf.lex_start_p <- buf.lex_curr_p;
    buf.lex_curr_p <- {buf.lex_curr_p
                       with pos_cnum = buf.lex_abs_pos + buf.lex_curr_pos};
  end;
  result


let new_engine tbl state buf =
  let result = c_new_engine tbl state buf in
  if result >= 0 && buf.lex_curr_p != dummy_pos then begin
    buf.lex_start_p <- buf.lex_curr_p;
    buf.lex_curr_p <- {buf.lex_curr_p
                       with pos_cnum = buf.lex_abs_pos + buf.lex_curr_pos};
  end;
  result

let lex_refill read_fun aux_buffer lexbuf =
  let read =
    read_fun aux_buffer (Bytes.length aux_buffer) in
  let n =
    if read > 0
    then read
    else (lexbuf.lex_eof_reached <- true; 0) in
  (* Current state of the buffer:
        <-------|---------------------|----------->
        |  junk |      valid data     |   junk    |
        ^       ^                     ^           ^
        0    start_pos             buffer_end    Bytes.length buffer
  *)
  if lexbuf.lex_buffer_len + n > Bytes.length lexbuf.lex_buffer then begin
    (* There is not enough space at the end of the buffer *)
    if lexbuf.lex_buffer_len - lexbuf.lex_start_pos + n
       <= Bytes.length lexbuf.lex_buffer
    then begin
      (* But there is enough space if we reclaim the junk at the beginning
         of the buffer *)
      Bytes.blit lexbuf.lex_buffer lexbuf.lex_start_pos
                  lexbuf.lex_buffer 0
                  (lexbuf.lex_buffer_len - lexbuf.lex_start_pos)
    end else begin
      (* We must grow the buffer.  Doubling its size will provide enough
         space since n <= String.length aux_buffer <= String.length buffer.
         Watch out for string length overflow, though. *)
      let newlen =
#ifdef BS
       (2 * Bytes.length lexbuf.lex_buffer)
#else
        Int.min (2 * Bytes.length lexbuf.lex_buffer) Sys.max_string_length in
#endif
      in
      if lexbuf.lex_buffer_len - lexbuf.lex_start_pos + n > newlen
      then failwith "Lexing.lex_refill: cannot grow buffer";
      let newbuf = Bytes.create newlen in
      (* Copy the valid data to the beginning of the new buffer *)
      Bytes.blit lexbuf.lex_buffer lexbuf.lex_start_pos
                  newbuf 0
                  (lexbuf.lex_buffer_len - lexbuf.lex_start_pos);
      lexbuf.lex_buffer <- newbuf
    end;
    (* Reallocation or not, we have shifted the data left by
       start_pos characters; update the positions *)
    let s = lexbuf.lex_start_pos in
    lexbuf.lex_abs_pos <- lexbuf.lex_abs_pos + s;
    lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos - s;
    lexbuf.lex_start_pos <- 0;
    lexbuf.lex_last_pos <- lexbuf.lex_last_pos - s;
    lexbuf.lex_buffer_len <- lexbuf.lex_buffer_len - s ;
    let t = lexbuf.lex_mem in
    for i = 0 to Array.length t-1 do
      let v = t.(i) in
      if v >= 0 then
        t.(i) <- v-s
    done
  end;
  (* There is now enough space at the end of the buffer *)
  Bytes.blit aux_buffer 0 lexbuf.lex_buffer lexbuf.lex_buffer_len n;
  lexbuf.lex_buffer_len <- lexbuf.lex_buffer_len + n

let zero_pos = {
  pos_fname = "";
  pos_lnum = 1;
  pos_bol = 0;
  pos_cnum = 0;
}

let from_function ?(with_positions = true) f =
  { refill_buff = lex_refill f (Bytes.create 512);
    lex_buffer = Bytes.create 1024;
    lex_buffer_len = 0;
    lex_abs_pos = 0;
    lex_start_pos = 0;
    lex_curr_pos = 0;
    lex_last_pos = 0;
    lex_last_action = 0;
    lex_mem = [||];
    lex_eof_reached = false;
    lex_start_p = if with_positions then zero_pos else dummy_pos;
    lex_curr_p = if with_positions then zero_pos else dummy_pos;
  }

let from_channel ?with_positions ic =
  from_function ?with_positions (fun buf n -> input ic buf 0 n)

let from_string ?(with_positions = true) s =
  (* We can't use [Bytes.unsafe_of_string] here,
     [lex_buffer] is exported in the mli, one can mutate
     it outside this module. *)
  let lex_buffer = Bytes.of_string s in
  { refill_buff = (fun lexbuf -> lexbuf.lex_eof_reached <- true);
    lex_buffer;
    lex_buffer_len = Bytes.length lex_buffer;
    lex_abs_pos = 0;
    lex_start_pos = 0;
    lex_curr_pos = 0;
    lex_last_pos = 0;
    lex_last_action = 0;
    lex_mem = [||];
    lex_eof_reached = true;
    lex_start_p = if with_positions then zero_pos else dummy_pos;
    lex_curr_p = if with_positions then zero_pos else dummy_pos;
  }

let set_position lexbuf position =
  lexbuf.lex_curr_p  <- {position with pos_fname = lexbuf.lex_curr_p.pos_fname};
  lexbuf.lex_abs_pos <- position.pos_cnum

let set_filename lexbuf fname =
  lexbuf.lex_curr_p <- {lexbuf.lex_curr_p with pos_fname = fname}

let with_positions lexbuf = lexbuf.lex_curr_p != dummy_pos

let lexeme lexbuf =
  let len = lexbuf.lex_curr_pos - lexbuf.lex_start_pos in
  Bytes.sub_string lexbuf.lex_buffer lexbuf.lex_start_pos len

let sub_lexeme lexbuf i1 i2 =
  let len = i2-i1 in
  Bytes.sub_string lexbuf.lex_buffer i1 len

let sub_lexeme_opt lexbuf i1 i2 =
  if i1 >= 0 then begin
    let len = i2-i1 in
    Some (Bytes.sub_string lexbuf.lex_buffer i1 len)
  end else begin
    None
  end

let sub_lexeme_char lexbuf i = Bytes.get lexbuf.lex_buffer i

let sub_lexeme_char_opt lexbuf i =
  if i >= 0 then
    Some (Bytes.get lexbuf.lex_buffer i)
  else
    None


let lexeme_char lexbuf i =
  Bytes.get lexbuf.lex_buffer (lexbuf.lex_start_pos + i)

let lexeme_start lexbuf = lexbuf.lex_start_p.pos_cnum
let lexeme_end lexbuf = lexbuf.lex_curr_p.pos_cnum

let lexeme_start_p lexbuf = lexbuf.lex_start_p
let lexeme_end_p lexbuf = lexbuf.lex_curr_p

let new_line lexbuf =
  let lcp = lexbuf.lex_curr_p in
  if lcp != dummy_pos then
    lexbuf.lex_curr_p <-
      { lcp with
        pos_lnum = lcp.pos_lnum + 1;
        pos_bol = lcp.pos_cnum;
      }



(* Discard data left in lexer buffer. *)

let flush_input lb =
  lb.lex_curr_pos <- 0;
  lb.lex_abs_pos <- 0;
  let lcp = lb.lex_curr_p in
  if lcp != dummy_pos then
    lb.lex_curr_p <- {zero_pos with pos_fname = lcp.pos_fname};
  lb.lex_buffer_len <- 0;
