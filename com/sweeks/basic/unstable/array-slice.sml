(* Copyright (C) 2006 Stephen Weeks.
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)
structure ArraySlice: ARRAY_SLICE = struct

   structure Slice = struct

      type 'a t = 'a ArraySlice.slice
      type 'a elem = 'a

      local
         open ArraySlice
      in
         val full = full
         val size = length
         val sub = sub
      end
   
      fun base s = let
         val (a, i, _) = ArraySlice.base s
      in
         (a, {start = i})
      end

      fun slice (s, {size, start}) = ArraySlice.subslice (s, start, SOME size)
   end

   open Slice

   structure S = Slice (structure Base = Array
                        open Slice)

   open S
                           
end
                                  
