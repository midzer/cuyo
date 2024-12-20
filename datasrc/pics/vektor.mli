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

exception Falsche_Dimension

module Vektor : functor(D : Nat) -> sig
  (* Vektoren der Länge D.n *)

  type t

  val compare : t -> t -> int
  val to_string : t -> string

  val koord : t -> int -> float
  val setz_koord : t -> int -> float -> t

  val einheit : int -> t
  val aus_funktion : (int -> float) -> t
  val aus_array : float array -> t
  val zu_array : t -> float array

  val plus : t -> t -> t
  val mal : float -> t -> t
  val produkt : t -> t -> float
  val abstand2 : t -> t -> float
    (* euklidischer Abstand im Quadrat *)
  val laenge : t -> float

end

module Laenger : functor(D : Nat) -> functor(D' : Nat) -> sig
  val laenger : Vektor(D).t -> Vektor(D').t
end

module Kuerzer : functor(D : Nat) -> functor(D' : Nat) -> sig
  val kuerzer : Vektor(D).t -> Vektor(D').t
end



module Matrix : functor(D1:Nat) -> functor(D2:Nat) -> sig
  (* Matrizen mit D1.n Zeilen und D2.n Spalten
     Zeilenindices kommen immer zuerst *)

  type t

  val aus_funktion : (int -> int -> float) -> t

  val plus : t -> t -> t
  val mal_skalar : float -> t -> t
  val mal_vektor : t -> Vektor(D2).t -> Vektor(D1).t

end



module QuadMatrix : functor(D:Nat) -> sig
  (* Zeug für quadratische Matrizen *)

  val eigenvektor1 : Matrix(D)(D).t -> Vektor(D).t
    (* Liefert einen normierten Eigenvektor zum betragsgrößten Eigenwert *)

end

