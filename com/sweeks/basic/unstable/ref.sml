(* Copyright (C) 2006 Stephen Weeks.
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)
structure Ref: REF = struct
   
   datatype t = datatype Ref.t

   val ! = !
   val op := = op := 

end

local
   open Ref
in
   val ! = !
   val op := = op :=
end
