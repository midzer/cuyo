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

let pi = 4.0 *. atan 1.0

let list_for a b f =
  let rec doit i = if i>b
  then []
  else (f i)::(doit (i+1))  in
  doit a

let list_for a b f = if a<=b
  then list_for a b f
  else List.rev (list_for b a f)

let array_foldi f a aa = snd (Array.fold_left
  (fun (i,a) -> fun b -> i+1, f a i b)
  (0,a)
  aa)

let prefix s n = String.sub s 0 n
let suffix s n = String.sub s (String.length s - n) n
let coprefix s n = String.sub s n (String.length s - n)
let cosuffix s n = String.sub s 0 (String.length s - n)

let xor b1 b2 = if b1  then not b2  else b2

let id x = x

