(*
   Copyright 2006 by Mark Weyer

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

open Natmod

exception Falsche_Laenge
exception Falsche_Dimension

let eps = 1e-10

module Vektor = functor(D : Nat) -> struct

  type t = float array

  let to_string v =
    let rec rest s i = if i=D.n
      then s^")"
      else rest
        (s^(if i>0 then ", " else "")^(string_of_float v.(i)))
        (i+1)  in
    rest "(" 0

  let koord t i = t.(i)
  let setz_koord v i x = Array.init D.n (function i' ->
    if i=i'  then x  else v.(i'))

  let einheit i = if i>=D.n
    then raise Falsche_Laenge
    else
      (let v = Array.make D.n 0.0  in
      v.(i) <- 1.0;
      v)

  let aus_funktion f = Array.init D.n (fun i -> f i)

  let aus_array a = if Array.length a != D.n
    then raise Falsche_Laenge
    else a

  let zu_array v = v

  let plus v1 v2 = Array.mapi (fun i -> fun x -> x+.v2.(i)) v1
  let mal a = Array.map (fun x -> x*.a)

  let fold2 f a v1 v2 =
    let rec fold a i = if i=D.n
      then a
      else fold (f a v1.(i) v2.(i)) (i+1)  in
    fold a 0

  let compare = fold2
    (fun c -> fun x1 -> fun x2 -> if c=0
      then if abs_float (x1-.x2) < eps
	then 0
        else if x1<x2  then -1  else 1
      else c)
    0
  let produkt = fold2 (fun p -> fun x1 -> fun x2 -> p+.x1*.x2) 0.0
  let abstand2 = fold2
    (fun d -> fun x1 -> fun x2 -> let dx = x2-.x1  in d+.dx*.dx)
    0.0
  let laenge v = sqrt (produkt v v)

end

module Laenger = functor (D : Nat) -> functor (D' : Nat) -> struct

  let test = if D'.n < D.n  then raise Falsche_Dimension

  let laenger v = Array.init D'.n
    (function i -> if i<D.n  then v.(i)  else 0.0)

end

module Kuerzer = functor (D : Nat) -> functor (D' : Nat) -> struct

  let test = if D'.n > D.n  then raise Falsche_Dimension

  let kuerzer v = Array.init D'.n (function i -> v.(i))

end






module Matrix = functor(D1:Nat) -> functor(D2:Nat) -> struct

  module V2 = Vektor(D2)

  type t = float array array

  let aus_funktion f = Array.init D1.n
    (fun i -> Array.init D2.n
      (fun j -> f i j))

  let plus m1 m2 = aus_funktion (fun i -> fun j -> m1.(i).(j) +. m2.(i).(j))
  let mal_skalar s m = aus_funktion (fun i -> fun j -> s *. m.(i).(j))

  let mal_vektor m v = Array.init D1.n
    (fun i -> V2.produkt m.(i) v)

end



module QuadMatrix = functor(D:Nat) -> struct

  module V = Vektor(D)
  module M = Matrix(D)(D)

  exception Schlechte_Wahl

  let eps = 1e-10

  let eigenvektor1 m =
    let eps2 = eps*.eps  in
    let rec iteriere v =
      let v' = M.mal_vektor m v  in
      let l = V.laenge v  in
      if l<eps
        then raise Schlechte_Wahl
        else
          let v'' = V.mal (1.0/.l) v'  in
          if V.abstand2 v v'' < eps2
            then v''
	    else iteriere v''  in
    let rec versuche i = if i>=D.n
      (* Wir gehen alle Einheitsvektoren als Startvektoren durch,
	 bis mal einer klappt. i ist der aktuelle Index. *)
    then V.einheit 0   (* Alle erfolglos probiert
			  -> Nullmatrix
			  -> beliebiger normierter Vektor *)
    else try
      iteriere (V.einheit i)
    with
      Schlechte_Wahl -> versuche (i+1)  in
    versuche 0



end

