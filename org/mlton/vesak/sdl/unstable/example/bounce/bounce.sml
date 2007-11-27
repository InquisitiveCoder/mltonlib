(* Copyright (C) 2007 Vesa Karvonen
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

open SDL

val printlns = println o concat

structure Opt = struct
   val w = ref 640
   val h = ref 480
   val bpp = ref 16
   val size = ref 4
   val num = ref 100
end

structure G = struct
   open RanQD1Gen
   local
      val r = ref (RNG.make (RNG.Seed.fromWord (valOf (RandomDev.useed ()))))
   in
      fun gen g = generate 1 (!r before r := RNG.next (!r)) g
   end
end

fun main () = let
   val surface =
       Video.setMode Prop.HWSURFACE {bpp = !Opt.bpp} {w = !Opt.w, h = !Opt.h}

   val black = Color.fromRGB surface {r=0w0, g=0w0, b=0w0}
   val white = Color.fromRGB surface {r=0w255, g=0w255, b=0w255}

   val xMax = real (!Opt.w - !Opt.size)
   val yMax = real (!Opt.h - !Opt.size)

   val obs =
       Vector.tabulate
          (!Opt.num,
           fn _ => let
                 open G
              in
                 {x = ref (gen (realInRange (0.0, xMax))),
                  y = ref (gen (realInRange (0.0, yMax))),
                  dx = ref (gen (realInRange (~5.0, 5.0))),
                  dy = ref (gen (realInRange (~5.0, 5.0)))}
              end)

   fun render () =
       (fillRect surface black NONE
      ; Vector.app (fn {x, y, ...} =>
                       fillRect surface white (SOME {x = trunc (!x),
                                                     y = trunc (!y),
                                                     w = !Opt.size,
                                                     h = !Opt.size}))
                   obs
      ; Surface.updateRect surface NONE)

   fun animate () =
       Vector.app (fn {x, y, dx, dy} =>
                      (if !x < 0.0 andalso !dx < 0.0 orelse
                          xMax < !x andalso 0.0 < !dx then
                          dx := ~ (!dx)
                       else ()
                     ; if !y < 0.0 andalso !dy < 0.0 orelse
                          yMax < !y andalso 0.0 < !dy then
                          dy := ~ (!dy)
                       else ()
                     ; x := !x + !dx
                     ; y := !y + !dy))
                  obs

   fun sleep () = OS.Process.sleep (Time.fromMilliseconds 20)

   fun lp () =
       case Event.poll ()
        of SOME (Event.KEY {key, pressed = true, down = true, ...}) =>
           if key = Key.Q orelse key = Key.ESCAPE then () else lp ()
         | _ => (render () ; animate () ; sleep () ; lp ())
in
   lp ()
end

val () =
    recur (CommandLine.arguments ()) (fn lp =>
       fn []                 => (init Init.VIDEO ; after (main, quit))
        | "-bpp"  :: v :: xs => (Opt.bpp  := valOf (Int.fromString v) ; lp xs)
        | "-w"    :: v :: xs => (Opt.w    := valOf (Int.fromString v) ; lp xs)
        | "-h"    :: v :: xs => (Opt.h    := valOf (Int.fromString v) ; lp xs)
        | "-size" :: v :: xs => (Opt.size := valOf (Int.fromString v) ; lp xs)
        | "-num"  :: v :: xs => (Opt.num  := valOf (Int.fromString v) ; lp xs)
        | x :: _             => (printlns ["Invalid option: ", x]))
