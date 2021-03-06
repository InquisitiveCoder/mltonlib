(* Copyright (C) 2006 SSH Communications Security, Helsinki, Finland
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

(** == Extended {MONO_ARRAY_SLICE} modules for Poly/ML == *)

structure IntArraySlice : MONO_ARRAY_SLICE =
   MkMonoArraySliceExt (structure MonoArraySlice = IntArraySlice)

structure RealArraySlice : MONO_ARRAY_SLICE =
   MkMonoArraySliceExt (structure MonoArraySlice = RealArraySlice)
