(*
   Copyright 2009 by Mark Weyer
   This is a manual conversion of highlight.pov which was
     Copyright 2006 by Mark Weyer
   Maintenance modifications 2011 by the cuyo developers

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

open Farbe
open Graphik

let farbe r g b = rgbrgb
  (float_of_int r /. 255.0) (float_of_int g /. 255.0) (float_of_int b /. 255.0)

let highlightrad = 16         (* Immer an blatt.h anpassen :-(  *)
let farbe1 = farbe 30 30 70   (* Immer an blatt.cpp anpassen :-(  *)
let farbe2 = farbe 50 50 120  (* Immer an menueintrag.cpp anpassen :-(  *)

let rad2 = float_of_int highlightrad /.32.0
let rad1 = rad2/.3.0

let bild = (3,3,fun (x,y) ->
  let f1,f2 = von_rgb farbe1, von_rgb farbe2  in
  let konv x = max 0.0 (abs_float(1.5-.x)-.0.5)  in
  let x,y = konv x, konv y  in
  let r = sqrt (x*.x+.y*.y)  in
  if r<rad1
  then f2
  else if r>rad2
    then durchsichtig
    else misch2 f2 f1 ((r-.rad1)/.(rad2-.rad1)))

let raus gric name = gib_xpm_aus farbe1 name (berechne gric bild)

;;

let synopsis = "highlight options gric"  in
let outname = Easyarg.register_string_with_default "-o" "Output file name"
  "highlight.xpm"  in

let gric =
  try
    let [gric] = Easyarg.parse synopsis  in
    int_of_string gric
  with
  | _ -> (
    Easyarg.usage synopsis;
    flush stderr;
    raise (Arg.Bad ""))  in

raus gric !outname

