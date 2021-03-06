(* Copyright (C) 2006 SSH Communications Security, Helsinki, Finland
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

(** Utilities for dealing with bit-wise shift operators. *)
signature SHIFT_OP = sig
   type 'a t = 'a * Word.t -> 'a
   (** Type of bit-wise shift operators {<<, >>, ~>>}. *)
end
