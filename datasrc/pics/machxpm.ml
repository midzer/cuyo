(*
   Copyright 2006-2008,2010,2011,2014 by Mark Weyer

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

exception Usage_Error of string

open Farbe
open Graphik
open Helfer

module Colour = struct

  type t = farbe

  let from_string s = match s  with
  | "trans" -> durchsichtig
  | s ->
    let rgslash = String.index s '/'  in
    let gbslash = String.index_from s (rgslash+1) '/'  in
    let red = int_of_string (prefix s rgslash)  in
    let green = int_of_string
      (String.sub s (rgslash+1) (gbslash-rgslash-1))  in
    let blue = int_of_string (coprefix s (gbslash+1))  in
    let f x = (float_of_int x)/.255.0  in
    von_rgb (rgbrgb (f red) (f green) (f blue))

end

module Pixel = struct

  type t = int * int

  let from_string s =
    let slash = String.index s '/'  in
    let x = int_of_string (prefix s slash)  in
    let y = int_of_string (coprefix s (slash+1))  in
    x,y

end

module Reg_Colour = Easyarg.Register(Colour)
module Reg_Pixel = Easyarg.Register(Pixel)



let format = Easyarg.register_choices [
    "-ppm", "Expect ppm input format";
    "-rgba", "Expect RGBA pam input format";
    "-xpm", "Expect xpm input format";
  ]

let qmethod = Easyarg.register_choices [
    "-average", "Try to minimize average error when quantizing";
    "-maximal", "Try to minimize maximal error when quantizing";
  ]

let colours = Easyarg.register_int_without_default
  "-colours"  "Maximal number of output colours"

let chars = Easyarg.register_int_without_default
  "-chars"  "Maximal number of output chars per pixel"

let recolour = Reg_Colour.register_without_default
  "-recolour"
  "Colour in format r/g/b (or \"trans\") to replace for red channel"

let transcolour = Reg_Colour.register_without_default
  "-transcolour"
  "Colour in format r/g/b (or \"trans\") for bluescreening"

let includepixelcolour = Reg_Pixel.register_list
  "-includepixelcolour"
  "Pixel in format x/y which colour to include in colourspace"

let outname = Easyarg.register_string_without_default "-o"
  "Output file name. Defaults to infile.xpm if there is exactly one infile"

let width = Easyarg.register_int_without_default
  "-width"  "Output width"


let rec hoch a b = if b=0  then 1  else a*(hoch a (b-1))

let ersetz f f' = if f=f'  then durchsichtig  else f'

let bildmap f (w,h,pixel) = w,h, Array.map (Array.map f) pixel

let synopsis =  "machxpm options infiles"

;;

let anon = Easyarg.parse synopsis in

let farben = match !colours, !chars  with
| None, None -> anz_xpm_zeichen
| None, Some chars -> hoch anz_xpm_zeichen chars
| Some colours, None -> colours
| Some _, Some _ -> raise (Usage_Error
  "Only one of -colours and -chars may be used.")  in

let innames = anon  in

let outname = match !outname with
| None -> (match innames with
  | [inname] -> inname^".xpm"
  | _ -> (Easyarg.usage synopsis; raise (Arg.Bad "")))
| Some name -> name  in

let bilder = match !format  with
| Some "-ppm" -> List.map (fun inname -> lies_ppm (inname^".ppm")) innames
| Some "-rgba" -> List.map (fun inname -> lies_pam (inname^".pam")) innames
| Some "-xpm" -> List.map (fun inname -> lies_xpm (inname^".xpm")) innames
| _ -> raise (Usage_Error
  "Missing or invalid specification of input format.")  in 

let width = match !width with
| None -> (match bilder with
  | [w,_,_] -> w
  | _ -> raise (Usage_Error "Missing specification of output width."))
| Some w -> w  in

let bild =
  let spez,_,_,h = List.fold_left
    (fun (spez,x,y0,y1) bild ->
      let w,h,_ = bild  in
      let x,y0,y1 = if x+w<=width  then x,y0,max y1 (y0+h)  else 0,y1,y1+h  in
      (x,y0+h,abstrahiere 1 bild)::spez, x+w, y0, y1)
    ([],0,0,0)
    bilder  in
  let spez = List.map (fun (x,y,b) -> x,h-y,b) spez  in
  berechne 1 (kombiniere_bildchen width h spez)  in

let forced_colours =
  let w,h,c = bild  in
  Array.of_list (List.map (fun (x,y) -> c.(y).(x)) !includepixelcolour)  in

let bild = match !transcolour with
| None -> bild
| Some f -> bildmap (ersetz f) bild  in

let bild = match !recolour with
| None -> bild
| Some f -> bildmap (mischspezial f) bild  in

match !qmethod with
| None -> gib_xpm_aus_exakt (rgb_grau 0.0) outname bild
| Some "-average" -> gib_xpm_aus_palette (rgb_grau 0.0)
  (reduziere_farben Heuristik_mittlerer_euklidischer forced_colours farben bild)
  outname  bild
| Some "-maximal" -> gib_xpm_aus_palette (rgb_grau 0.0)
  (reduziere_farben Heuristik_maximaler_euklidischer forced_colours farben bild)
  outname  bild

