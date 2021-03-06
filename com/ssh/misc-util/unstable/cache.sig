(* Copyright (C) 2007 SSH Communications Security, Helsinki, Finland
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 *)

(**
 * Signature for an imperative polymorphic cache for storing values.  A
 * cache differs from an ordinary imperative polymorphic map in that a
 * cache automatically generates keys for values.
 *)
signature CACHE = sig
   type 'a t

   structure Key : sig
      type t
   end

   exception NotFound
   (**
    * Raised by {get}, {use}, and {rem} in case a key is not found from
    * the cache.  An attempt to use invalid or removed keys is considered
    * an error.
    *)

   val new : Unit.t -> 'a t
   (** Creates a new (empty) cache. *)

   val size : 'a t -> Int.t
   (** Returns the number of elements in the cache. *)

   val isEmpty : 'a t UnPr.t
   (** {isEmpty c} is equivalent to {size x = 0}. *)

   val putWith : 'a t -> (Key.t -> 'a) -> Key.t * 'a
   (**
    * Puts a key dependent value into cache and returns the key and
    * value.  If the construction of the value raises an exception, the
    * state of the cache will not change observably.
    *)

   val put : 'a t -> 'a -> Key.t
   (** Puts a value into cache and returns the key for the value. *)

   val get : 'a t -> Key.t -> 'a
   (** Returns the value corresponding to the key. *)

   val use : 'a t -> Key.t -> 'a
   (** Removes from the cache and returns the value corresponding to the key. *)

   val rem : 'a t -> Key.t -> Unit.t
   (** Removes from the cache the value corresponding to the key. *)

   val values : 'a t -> 'a List.t
   (** Returns a list of values in the cache. *)
end
