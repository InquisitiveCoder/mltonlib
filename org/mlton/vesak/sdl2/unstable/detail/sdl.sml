(* Copyright (C) 2007-2008 Vesa Karvonen
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

structure SDL :> SDL = struct
   structure F = MLton.Finalizable

   structure Word32Flags = MkWordFlags (Word32)
   structure Word8Flags = MkWordFlags (Word8)

   val op >< = With.Monad.><
   fun withNew size = With.around (fn () => C.new' size) C.discard'
   fun withAlloc alloc = With.around alloc C.free'
   fun withZs mlStr = withAlloc (fn () => ZString.dupML' mlStr)
   fun withArray size length = withAlloc (fn () => C.alloc' size length)
   fun withBuf length = withArray C.S.uchar length
   val one = With.one

   fun raiseError () = raise Fail (ZString.toML' (F_SDL_GetError.f' ()))
   fun checkInt code = if 0 = code then () else raiseError ()
   fun checkPtr ptr = if C.Ptr.isNull' ptr then raiseError () else ptr

   val minus1ptr : C.voidptr = C.U.i2p (C.Cvt.c_ulong (~ 0w1))

   structure Init = struct
      open Word32Flags
      val TIMER          = SDL_INIT_TIMER
      val AUDIO          = SDL_INIT_AUDIO
      val VIDEO          = SDL_INIT_VIDEO
      val JOYSTICK       = SDL_INIT_JOYSTICK
      val HAPTIC         = SDL_INIT_HAPTIC
      val GAMECONTROLLER = SDL_INIT_GAMECONTROLLER
      val EVENTS         = SDL_INIT_EVENTS
      val EVERYTHING     = SDL_INIT_EVERYTHING
      val NOPARACHUTE    = SDL_INIT_NOPARACHUTE
   end
   val init = checkInt o F_SDL_Init.f'
   val initSubSystem = checkInt o F_SDL_InitSubSystem.f'
   val quitSubSystem = F_SDL_QuitSubSystem.f'
   val wasInit = F_SDL_WasInit.f'
   val quit = F_SDL_Quit.f'

   structure Pos = struct type 'a t = {x : 'a, y : 'a} end
   structure Dim = struct type 'a t = {w : 'a, h : 'a} end
   structure Rect = struct type 'a t = {pos : 'a Pos.t, dim : 'a Dim.t} end
   structure RGB = struct
      type 'a t = {r : 'a, g : 'a, b : 'a}
      fun fromRGBA {r, g, b, a = _} = {r = r, g = g, b = b}
   end
   structure RGBA = struct
      type 'a t = {r : 'a, g : 'a, b : 'a, a : 'a}
      fun map f {r, g, b, a} = {r = f r, g = f g, b = f b, a = f a}
      fun zipWith f (l : 'a t, r : 'b t) =
          {r = f (#r l, #r r), g = f (#g l, #g r),
           b = f (#b l, #b r), a = f (#a l, #a r)}
      fun sum op + {r, g, b, a} = r + g + b + a
      fun binApp e = ignore o zipWith e
      fun dup x = {r=x, g=x, b=x, a=x}
      fun fromRGB a {r, g, b} = {r=r, g=g, b=b, a=a}
   end

   structure Pixel = struct
      type t = Word32.t

      structure Format = struct
         type t = {bits : Word8.t,
                   bytes : Word8.t,
                   mask : t RGBA.t,
                   shift : Word8.t RGBA.t,
                   loss : Word8.t RGBA.t}

         fun bits (t : t) = Word8.toWord (#bits t)
         fun bitsRGBA (t : t) =
             RGBA.map (fn x => 0w8 - Word8.toWord x) (#loss t)
         val bitsRGB = RGB.fromRGBA o bitsRGBA

         fun masks shift loss rgba =
             RGBA.zipWith Word32.<<
                          (RGBA.zipWith Word32.>>
                                        (RGBA.map Word32.fromWord8 rgba,
                                         RGBA.map Word8.toWord loss),
                           RGBA.map Word8.toWord shift)

         fun fromRGBA (rgba as {r, g, b, a}) : t = let
            val bits = RGBA.sum op + rgba
            val shift = {b = 0w0, g = b, r = g+b,
                         a = if 0w0 = a then 0w0 else r+g+b}
            val loss = RGBA.map (0w8 <\ op -) rgba
         in
            {bits = bits, bytes = (bits + 0w7) div 0w8,
             mask = masks shift loss (RGBA.dup 0w255),
             shift = shift, loss = loss}
         end

         val r5g6b5   = fromRGBA {r=0w5, g=0w6, b=0w5, a=0w0}
         val r8g8b8   = fromRGBA {r=0w8, g=0w8, b=0w8, a=0w0}
         val r8g8b8_8 = {bits = 0w32, bytes = 0w4,
                         mask = #mask r8g8b8, loss = #loss r8g8b8,
                         shift = #shift r8g8b8} : t
         val r8g8b8a8 = fromRGBA {r=0w8, g=0w8, b=0w8, a=0w8}

         local
            open S_SDL_PixelFormat
         in
            val f_loss  = {r=f_Rloss',  g=f_Gloss',  b=f_Bloss',  a=f_Aloss'}
            val f_mask  = {r=f_Rmask',  g=f_Gmask',  b=f_Bmask',  a=f_Amask'}
            val f_shift = {r=f_Rshift', g=f_Gshift', b=f_Bshift', a=f_Ashift'}
         end

         fun fromSDL pf = let
            open S_SDL_PixelFormat
            fun w f = C.Get.uint' (f pf)
            fun b f = C.Get.uchar' (f pf)
            val mask = RGBA.map w f_mask
         in
            {bits = b f_BitsPerPixel',
             bytes = b f_BytesPerPixel', mask = mask,
             shift = RGBA.map b f_shift,
             loss = RGBA.zipWith (fn (m, l) => if 0w0 = m then 0w8 else b l)
                                 (mask, f_loss)}
         end

         fun withSDL ({bits, bytes, mask, shift, loss} : t) =
             With.Monad.map
                (fn pf => let
                       fun w (f, v) = C.Set.uint' (f pf, v)
                       fun b (f, v) = C.Set.uchar' (f pf, v)
                       open S_SDL_PixelFormat
                    in
                       C.Set.ptr' (f_palette' pf, C.Ptr.null')
                     ; b (f_BitsPerPixel', bits)
                     ; b (f_BytesPerPixel', bytes)
                     ; RGBA.binApp b (f_loss, loss)
                     ; RGBA.binApp w (f_mask, mask)
                     ; RGBA.binApp b (f_shift, shift)
                     ; pf
                    end)
                (withNew S_SDL_PixelFormat.size)
      end

      fun fromRGBA ({shift, loss, ...} : Format.t) =
         RGBA.sum Word32.orb o Format.masks shift loss
      fun fromRGB format = fromRGBA format o RGBA.fromRGB 0w255
   end

   structure Surface = struct
      type 'a t = (T_SDL_Surface.t, C.rw) C.obj C.ptr' Ref.t F.t
      fun withPtr t f =
          F.withValue
             (t,
              fn ref p =>
                 if C.Ptr.isNull' p
                 then fail "Dangling surface"
                 else f p)
      fun freeRef r = (F_SDL_FreeSurface.f' (!r) ; r := C.Ptr.null')
      fun new p = case F.new (ref p) of f => (F.addFinalizer (f, freeRef) ; f)
      fun getPixelFormat s =
          withPtr s (Pixel.Format.fromSDL o C.Ptr.|*! o C.Get.ptr' o
                     S_SDL_Surface.f_format' o C.Ptr.|*!)
      fun getProps s =
          withPtr s (C.Get.uint' o S_SDL_Surface.f_flags' o C.Ptr.|*!)
      fun getDim s =
          withPtr s (fn p =>
                        {w = C.Get.sint' (S_SDL_Surface.f_w' (C.Ptr.|*! p)),
                         h = C.Get.sint' (S_SDL_Surface.f_h' (C.Ptr.|*! p))})
      fun free s = F.withValue (s, freeRef)
      fun fill s c =
          withPtr s (fn p => checkInt (F_SDL_FillRect.f' (p, C.Ptr.null', c)))
   end

   structure Video = struct
      val maxDriverNameSz = 256 (* XXX is this large enough? *)
      val toFloat = Real32.fromLarge IEEEReal.TO_NEAREST
   end

   structure Key = struct
      structure Code = Int32
      structure Sym = struct
         fun toString sym = ZString.toML' (checkPtr (F_SDL_GetKeyName.f' sym))
         open SDLKeySym
      end
      structure Mod = struct
         open Word16Flags
         local
            open E_'SDL_Keymod
         in
            val toML = Word16.fromInt o m2i
            val LSHIFT = toML e_KMOD_LSHIFT
            val RSHIFT = toML e_KMOD_RSHIFT
            val LCTRL  = toML e_KMOD_LCTRL
            val RCTRL  = toML e_KMOD_RCTRL
            val LALT   = toML e_KMOD_LALT
            val RALT   = toML e_KMOD_RALT
            val NUM    = toML e_KMOD_NUM
            val CAPS   = toML e_KMOD_CAPS
            val MODE   = toML e_KMOD_MODE
         end
      end
   end

   structure Mouse = struct
      structure Button = struct
         open Word8Flags
         val LEFT   = SDL_BUTTON_LMASK
         val MIDDLE = SDL_BUTTON_MMASK
         val RIGHT  = SDL_BUTTON_RMASK
         val X1     = SDL_BUTTON_X1MASK
         val X2     = SDL_BUTTON_X2MASK
      end

      local
         fun getMouse f =
             one (withArray C.S.sint 0w2)
                 (fn xy =>
                     (ignore (f (xy, C.Ptr.|+! C.S.sint (xy, 1)))
                    ; {x = C.Get.sint' (C.Ptr.|*! xy),
                       y = C.Get.sint' (C.Ptr.sub' C.S.sint (xy, 1))}))
      in
         fun getPos () = getMouse F_SDL_GetMouseState.f'
         fun getDelta () = getMouse F_SDL_GetRelativeMouseState.f'
      end

      fun getButtons () = (F_SDL_GetMouseState.f' (C.Ptr.null', C.Ptr.null'))
   end

   structure Event = struct
      datatype t =
         KEY of {down : Bool.t,
                 pressed : Bool.t,
                 code : Key.Code.t,
                 sym : Key.Sym.t,
                 mods : Key.Mod.flags}

      fun toML event = let
         val t = C.Get.uint' (U_SDL_Event.f_type' event)
         open E_'SDL_EventType
         fun is e = m2i e = MLRep.Int.Unsigned.toInt t
      in
         if is e_SDL_KEYDOWN orelse is e_SDL_KEYUP
         then let
               val ke = U_SDL_Event.f_key' event
               val ks = S_SDL_KeyboardEvent.f_keysym' ke
               open S_SDL_Keysym
            in
               SOME (KEY {down = is e_SDL_KEYDOWN,
                          pressed = SDL_PRESSED =
                                    C.Get.uchar'
                                       (S_SDL_KeyboardEvent.f_state' ke),
                          code = C.Get.enum' (f_scancode' ks),
                          sym = C.Get.sint' (f_sym' ks),
                          mods = C.Get.ushort' (f_mod' ks)})
            end
         else NONE (* We just ignore other events for now *)
      end

      fun poll () =
          one (withNew U_SDL_Event.size)
              (fn event =>
                  case F_SDL_PollEvent.f' (C.Ptr.|&! event)
                   of 0 => NONE
                    | 1 => toML event
                    | _ => raiseError ())

      fun wait () =
          one (withNew U_SDL_Event.size)
              (fn event =>
                  case F_SDL_WaitEvent.f' (C.Ptr.|&! event)
                   of 1 => (case toML event
                             of NONE => wait ()
                              | SOME e => e)
                    | _ => raiseError ())

      val pump = F_SDL_PumpEvents.f'
   end

   structure Image = struct
      fun loadBMP path =
          one (withZs path >< withZs "rb")
              (fn path & rb =>
                  Surface.new o checkPtr |< F_SDL_LoadBMP_RW.f'
                     (F_SDL_RWFromFile.f' (path, rb), 1))
      fun saveBMP surface path =
          one (withZs path >< withZs "wb")
              (fn path & wb =>
                  (Surface.withPtr surface)
                     (fn surface =>
                         (checkInt (F_SDL_SaveBMP_RW.f'
                                       (surface,
                                        F_SDL_RWFromFile.f' (path, wb),
                                        1)))))
   end
end
