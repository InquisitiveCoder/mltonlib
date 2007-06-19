(* Copyright (C) 2007 SSH Communications Security, Helsinki, Finland
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

(**
 * Signature for the domain of the {LayerGenericRep} functor.
 *)
signature LAYER_GENERIC_REP_DOM = sig
   structure Outer : OPEN_GENERIC_REP
   structure Closed : CLOSED_GENERIC_REP
end
