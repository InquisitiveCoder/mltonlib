(* Copyright (C) 2007 SSH Communications Security, Helsinki, Finland
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

local
   open Generic UnitTest

   structure BinTree = MkBinTree (Generic)

   fun testReduce zero binOp to fromT t2t toT value expect = let
      val reduce = makeReduce zero binOp to fromT t2t
   in
      testEq toT (fn () => {expect = expect, actual = reduce value})
   end

   structure Lambda =
      MkLambda (structure Id = struct
                   type t = String.t
                   val t = string
                end
                open Generic)

   structure Set = struct
      val empty = []
      fun singleton x = [x]
      fun union (xs, ys) = List.nubByEq op = (xs @ ys)
      fun difference (xs, ys) = List.filter (not o List.contains ys) xs
   end

   local
      open Set Lambda
      val refs = fn REF id => singleton id | _ => empty
      val decs = fn FUN (id, _) => singleton id | _ => empty
   in
      fun free term =
          difference
             (union (refs (out term),
                     makeReduce empty union free t t' term),
              decs (out term))
   end
in
   val () =
       unitTests
          (title "Generic.Reduce")

          (testReduce 0 op + id int list int [1, 2, 3] 6)
          (testReduce 0 op + (const 1) real list int [1.0, 4.0, 6.0] 3)
          (testReduce 0 op + id int (fn t => tuple (T t *` T int *` T t)) int
                      (1 & 3 & 7) 8)

          let open BinTree in
             testReduce [] op @ (fn x => [x]) int t (list int)
                        (BR (BR (LF, 0, LF), 1, BR (LF, 2, BR (LF, 3, LF))))
                        [0, 1, 2, 3]
          end

          (testEq (list string)
                  (fn () => let
                         open Lambda
                         fun ` f = IN o f
                      in
                         {actual = free (`APP (`FUN ("x",
                                                     `APP (`REF "y", `REF "x")),
                                               `FUN ("z",
                                                     `APP (`REF "x",
                                                           `APP (`REF "y",
                                                                 `REF "x"))))),
                          expect = ["y", "x"]}
                      end))

          $
end
