(* Copyright (C) 2007 SSH Communications Security, Helsinki, Finland
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

val () = let
   open Type UnitTest
   fun notFound ? = verifyFailsWith (fn PtrCache.NotFound => true | _ => false) ?
   fun eq (e, a) = verifyEq int {actual = a, expect = e}
in
   unitTests
      (title "PtrCache")

      (test (fn () => let
                   open PtrCache
                   val c = new ()
                   val () = eq (0, size c)
                   val k5 = put c 5
                   val () = (eq (1, size c)
                           ; notFound (fn () => putWith c (raising NotFound))
                           ; eq (1, size c)
                           ; eq (5, get c k5))
                   val k2 = put c 2
                   val () = (eq (2, size c)
                           ; eq (5, use c k5)
                           ; notFound (fn () => get c k5)
                           ; eq (1, size c))
                   val k3 = put c 3
                   val () = (eq (2, use c k2)
                           ; notFound (fn () => use c k2)
                           ; eq (1, size c)
                           ; eq (3, use c k3)
                           ; notFound (fn () => get c k3)
                           ; eq (0, size c))
                   val k1 = put c 1
                   val k0 = put c 0
                   val () = (eq (2, size c)
                           ; eq (1, get c k1)
                           ; eq (0, get c k0)
                           ; rem c k0
                           ; rem c k1
                           ; eq (0, size c))
                in
                   ()
                end))

      $
end
