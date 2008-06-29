(* Copyright (C) 2007 SSH Communications Security, Helsinki, Finland
 * Copyright (C) 2008 Vesa Karvonen
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

functor WithExtra (Arg : GENERIC) : GENERIC_EXTRA = struct
   (* <-- SML/NJ workaround *)
   open TopLevel
   infix  7 *`
   infix  6 +` |`
   infix  0 & &`
   infixr 0 -->
   (* SML/NJ workaround --> *)

   open Generics Arg

   fun C0' n = C0 (C n)
   fun C1' n = C1 (C n)
   fun R' n = R (L n)

   fun data' s = iso (data s)
   fun record' p = iso (record p)
   fun tuple' p = iso (tuple p)

   local
      fun lift f a = SOME (f a) handle Match => NONE
   in
      fun regExn0' n e p = regExn0 (C n) (e, lift p)
      fun regExn1' n t e p = regExn1 (C n) t (e, lift p)
   end

   local
      fun mk t = iso (tuple t)
   in
      fun tuple2 (a, b) = mk (T a *` T b) Product.isoTuple2
      fun tuple3 (a, b, c) = mk (T a *` T b *` T c) Product.isoTuple3
      fun tuple4 (a, b, c, d) = mk (T a *` T b *` T c *` T d) Product.isoTuple4
   end

   local
      val fits = fn (SOME n, SOME m) => n <= m
                  | _                => false
      fun mk precision int' fixed' large' =
          if      fits (precision,      Int.precision) then iso      int   int'
          else if fits (precision, FixedInt.precision) then iso fixedInt fixed'
          else                                              iso largeInt large'
   in
      val int32 = let open Int32 in mk precision isoInt isoFixedInt isoLarge end
(*
      val int64 = let open Int64 in mk precision isoInt isoFixedInt isoLarge end
*)
      val position =
          let open Position in mk precision isoInt isoFixedInt isoLarge end
   end

   local
      val none = C "NONE"
      val some = C "SOME"
   in
      fun option a =
          iso (data (C0 none +` C1 some a))
              (fn NONE => INL () | SOME a => INR a,
               fn INL () => NONE | INR a => SOME a)
   end

   val order =
       iso (data (C0' "LESS" +` C0' "EQUAL" +` C0' "GREATER"))
           (fn LESS => INL (INL ())
             | EQUAL => INL (INR ())
             | GREATER => INR (),
            fn INL (INL ()) => LESS
             | INL (INR ()) => EQUAL
             | INR () => GREATER)

   local
      val et = C "&"
   in
      fun a &` b = data (C1 et (tuple (T a *` T b)))
   end

   local
      val inl = C "INL"
      val inr = C "INR"
   in
      fun a |` b = data (C1 inl a +` C1 inr b)
   end

   fun sq a = tuple2 (Sq.mk a)
   fun unOp a = a --> a
   fun binOp a = sq a --> a
end
