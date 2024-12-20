(*
   Copyright 2006,2011 by Mark Weyer
   Maintenance modifications 2010,2011 by the cuyo developers

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

exception Nullpolynom

val loese_2_normiert: float -> float -> float list
  (* loese_2_normiert a b löst  x^2 + ax + b = 0 *)

val loese_2: float -> float -> float -> float list
  (* loese_2 a b c löst  ax^2 + bx + c = 0 *)

val loese_3: float -> float -> float -> float -> float list
  (* loese_3 a b c d löst  ax^3 + bx^2 + cx + d = 0 *)

val loese_4: float -> float -> float -> float -> float -> float list
  (* loese_4 a b c d e löst  ax^4 + bx^3 + cx^2 + dx + e = 0 *)

(* Ausgegeben werden jeweils alle reellen Nullstellen (mit Vielfachheiten).
   Sind das zu viele, dann liegt das Nullpolynom vor und die entsprechende
   exception wird geraist. *)


val loese_2_2:
  float -> float -> float -> float -> float -> float ->
  float -> float -> float -> float -> float -> float ->
  (float*float) list
  (* loese_2_2 a20 a11 a02 a10 a01 a00 b20 b11 b02 b10 b01 b00 löst das System
       a20x^2 + a11xy + a02y^2 + a10x + a01y + a00 = 0
       b20x^2 + b11xy + b02y^2 + b10x + b01y + b00 = 0 *)

