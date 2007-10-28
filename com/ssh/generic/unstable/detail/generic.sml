(* Copyright (C) 2007 SSH Communications Security, Helsinki, Finland
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

(* WARNING: This file was generated by running 'Generate-combination.sh' script as:
 *
 *> Generate-combination.sh lib-with-default.mlb detail/generic.sml
 *)

signature Generic = CASES

functor MkGeneric (Arg : Generic) : Generic = Arg

structure Generic = RootGeneric

signature Generic = sig
   include Generic EQ
end

functor MkGeneric (Arg : Generic) = struct
   structure Open = MkGeneric (Arg)
   open Arg Open
   structure EqRep = Open.Rep
end

structure Generic =
   MkGeneric (structure Open = WithEq (Generic)
              open Generic Open)

signature Generic = sig
   include Generic TYPE_HASH
end

functor MkGeneric (Arg : Generic) = struct
   structure Open = MkGeneric (Arg)
   open Arg Open
   structure TypeHashRep = Open.Rep
end

structure Generic =
   MkGeneric (structure Open = WithTypeHash (Generic)
              open Generic Open)

signature Generic = sig
   include Generic TYPE_INFO
end

functor MkGeneric (Arg : Generic) = struct
   structure Open = MkGeneric (Arg)
   open Arg Open
   structure TypeInfoRep = Open.Rep
end

structure Generic =
   MkGeneric (structure Open = WithTypeInfo (Generic)
              open Generic Open)

signature Generic = sig
   include Generic HASH
end

functor MkGeneric (Arg : Generic) = struct
   structure Open = MkGeneric (Arg)
   open Arg Open
   structure HashRep = Open.Rep
end

structure Generic =
   MkGeneric (structure Open = WithHash (Generic)
              open Generic Open)

signature Generic = sig
   include Generic ORD
end

functor MkGeneric (Arg : Generic) = struct
   structure Open = MkGeneric (Arg)
   open Arg Open
   structure OrdRep = Open.Rep
end

structure Generic =
   MkGeneric (structure Open = WithOrd (Generic)
              open Generic Open)

signature Generic = sig
   include Generic PRETTY
end

functor MkGeneric (Arg : Generic) = struct
   structure Open = MkGeneric (Arg)
   open Arg Open
   structure PrettyRep = Open.Rep
end

structure Generic =
   MkGeneric (structure Open = WithPretty (Generic)
              open Generic Open)

structure Generic = struct
   structure Rep = ClosePrettyWithExtra (Generic)
   open Generic Rep
end
