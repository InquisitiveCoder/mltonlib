signature REF = sig

   datatype t = datatype Ref.t
   (**
    * SML's reference type.
    *)

   val ! : 'a t -> 'a
   (**
    * !r returns the value stored in r.
    *)
   val := : 'a t * 'a -> Unit.t
   (**
    * r := v changes the value in r to v.
    *)

end
