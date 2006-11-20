(* Copyright (C) 2006 SSH Communications Security, Helsinki, Finland
 *
 * MLton is released under a BSD-style license.
 * See the file MLton-LICENSE for details.
 *)

(** == Extended scalar modules common to all compilers == *)

structure Int = MkIntegerExt (Int)
structure LargeInt = MkIntegerExt (LargeInt)
structure Position = MkIntegerExt (Position)

structure LargeReal = MkRealExt (LargeReal)
structure Real = MkRealExt (Real)

structure LargeWord = MkWordExt (LargeWord)
structure Word = MkWordExt (Word)
structure Word8 = MkWordExt (Word8)
