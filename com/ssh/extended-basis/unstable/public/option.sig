(* Copyright (C) 2006 SSH Communications Security, Helsinki, Finland
 *
 * MLton is released under a BSD-style license.
 * See the file MLton-LICENSE for details.
 *)

(** Extended {OPTION} signature. *)
signature OPTION = sig
   include OPTION

   type 'a t = 'a option
   (** Convenience alias. *)

   val isNone : 'a t UnPr.t
   (** Returns {true} if given option is {NONE}; otherwise returns {false}. *)
end
