(*
   Copyright 2010,2011 by Mark Weyer

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

val pi : float

val list_for : int -> int -> (int -> 'a) -> 'a list
val array_foldi : ('a -> int -> 'b -> 'a) -> 'a -> 'b array -> 'a

val prefix : string -> int -> string
val suffix : string -> int -> string
val coprefix : string -> int -> string
val cosuffix : string -> int -> string

val xor : bool -> bool -> bool

val id : 'a -> 'a

