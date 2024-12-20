(*
   Copyright 2006 by Mark Weyer
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

open Farbe
open Graphik
open Vektorgraphik
open Helfer

open Male_mit_aa


let orange = von_rgb (rgbrgb 1.0 0.7 0.0)
let abstand = 0.05

type kante = float * float * float -> float -> polygon
  (* floats: ragen nach oben und unten.
     float-Argumente: ragen links und rechts *)

let gerade_kante = 0.0,0.0,
  function l -> function r -> [Strecke ((l,0.0),(1.0-.r,0.0))]

let nupsi1_kante,nupsi2_kante =
  let rad1,rad2 = 0.02, 0.1  in
  let h = (rad1+.rad2)*.(sqrt 0.5)  in
  (h+.rad1+.rad2, 0.0, function l -> function r -> [
    Strecke ((l,0.0),(0.5-.h,0.0));
    Bogen ((0.5-.h,rad1),rad1,true,pi*.1.5,pi*.0.25);
    Bogen ((0.5,h+.rad1),rad2,false,pi*.1.25,pi*.1.75);
    Bogen ((0.5+.h,rad1),rad1,true,pi*.0.75,pi*.1.5);
    Strecke ((0.5+.h,0.0),(1.0-.r,0.0));]),
  (0.0, h+.rad1+.rad2, function l -> function r -> [
    Strecke ((l,0.0),(0.5-.h,0.0));
    Bogen ((0.5-.h,-.rad1),rad1,false,pi*.0.5,pi*.1.75);
    Bogen ((0.5,-.h-.rad1),rad2,true,pi*.0.75,pi*.0.25);
    Bogen ((0.5+.h,-.rad1),rad1,false,pi*.1.25,pi*.0.5);
    Strecke ((0.5+.h,0.0),(1.0-.r,0.0));])

let nupsi3_kante = (* Der symmetrische Nupsi *)
  let rad1,rad2,d = 0.02, 0.07, 0.05  in
  let h1,h2,h3 = rad1+.2.0*.rad2, 2.0*.rad2, rad1+.d  in
  h3+.rad2, h3+.rad2, function l -> function r -> [
    Strecke ((l,0.0),(0.5-.h1,0.0));
    Bogen ((0.5-.h1,rad1),rad1,true,pi*.1.5,0.0);
    Strecke ((0.5-.h2,rad1),(0.5-.h2,h3));
    Bogen ((0.5-.rad2,h3),rad2,false,pi,0.0);
    Strecke ((0.5,h3),(0.5,-.h3));
    Bogen ((0.5+.rad2,-.h3),rad2,true,pi,0.0);
    Strecke ((0.5+.h2,-.h3),(0.5+.h2,-.rad1));
    Bogen ((0.5+.h1,-.rad1),rad1,false,pi,pi*.0.5);
    Strecke ((0.5+.h1,0.0),(1.0-.r,0.0));
  ]

let nupsi4_kante,nupsi5_kante =
  let d1,d2 = 0.2, 0.15  in
  (d2, 0.0, function l -> function r -> [
    Strecke ((l,0.0),(0.5-.d1,0.0));
    Spline ((0.5-.d1,0.0),(0.5,0.0),(0.5-.d1,d2),(0.5,d2));
    Spline ((0.5,d2),(0.5+.d1,d2),(0.5,0.0),(0.5+.d1,0.0));
    Strecke ((0.5+.d1,0.0),(1.0-.r,0.0));]),
  (0.0, d2, function l -> function r -> [
    Strecke ((l,0.0),(0.5-.d1,0.0));
    Spline ((0.5-.d1,0.0),(0.5,0.0),(0.5-.d1,-.d2),(0.5,-.d2));
    Spline ((0.5,-.d2),(0.5+.d1,-.d2),(0.5,0.0),(0.5+.d1,0.0));
    Strecke ((0.5+.d1,0.0),(1.0-.r,0.0));])

let waagerecht = [gerade_kante; nupsi1_kante; nupsi5_kante;
    nupsi3_kante; nupsi2_kante; nupsi4_kante]

let senkrecht = List.map
  (function o,u,p -> o,u,
    function l -> function r -> drehe_polygon 90.0 (p l r))
  waagerecht

let bilder = (List.length waagerecht)*(List.length senkrecht)

let puzzle waagerecht senkrecht =
  let ow,uw,pw = waagerecht  in
  let ls,rs,ps = senkrecht  in
  let oben,unten,links,rechts =
    abstand+.ow, abstand+.uw, abstand+.ls, abstand+.rs  in
  let wkanten,skanten =
    List.map (function x,y,l,r -> verschiebe_polygon x y (pw l r)),
    List.map (function x,u,o -> verschiebe_polygon x 0.0 (ps u o))  in
  let wstriche,sstriche =
    List.map (function x1,x2,y -> Strecke ((x1,y),(x2,y))),
    List.map (function x,y1,y2 -> Strecke ((x,y1),(x,y2)))  in
  let vorwaerts = konvertiere_polygon (List.concat (
    (wkanten [2.0,unten,links,rechts; 4.0,unten,-.rechts,0.0]) @
    (skanten [2.0-.rechts,0.0,0.0; 3.0-.rechts,unten,oben]) @
    [wstriche [0.0,links,unten; 5.0,5.0-.rechts,1.0-.oben];
      sstriche [
        links,unten,0.0; 4.0-.rechts,0.0,unten;
        1.0+.links,1.0,1.0-.oben; 5.0-.rechts,1.0-.oben,1.0]]))  in
  let rueckwaerts = rueckwaerts (konvertiere_polygon (List.concat (
    (wkanten [0.0,1.0-.oben,0.0,-.links; 2.0,1.0-.oben,links,rechts]) @
    (skanten [2.0+.links,unten,oben; 3.0+.links,0.0,0.0]))))  in
  let aussen = [vorwaerts;rueckwaerts]  in
  let ersatz = [konvertiere_polygon (
    (wstriche [
      links,2.0-.rechts,0.0; 3.0+.links,4.0-.rechts,0.0;
      2.0-.rechts,1.0+.links,1.0; 5.0-.rechts,3.0+.links,1.0]) @
    (sstriche [0.0,1.0-.oben,unten; 5.0,unten,1.0-.oben]))]  in
  let innen = [konvertiere_polygon (List.concat (
    (wkanten [0.0,0.0,links,0.0; 1.0,0.0,0.0,rechts; 3.0,0.0,links,rechts;
      1.0,1.0,links,rechts; 3.0,1.0,links,0.0; 4.0,1.0,0.0,rechts]) @
    (skanten [0.0,unten,oben; 1.0,0.0,oben; 4.0,unten,0.0; 5.0,unten,oben])
    ))]  in
  male
    (erzeuge_vektorbild
      [flaeche orange (aussen@ersatz); Strich (schwarz,aussen@innen)])
    (1.0/.32.0)
    (monochrom durchsichtig 5 1)

let puzzles = kombiniere_bildchen 5 bilder (fst (List.fold_left
  (function bilder,y -> function waagerecht -> List.fold_left
    (function bilder,y -> function senkrecht ->
      (0,y,puzzle waagerecht senkrecht)::bilder, y+1)
    (bilder,y)  senkrecht)
  ([],0)  waagerecht))



;;

let gric,command,outname = Gen_common.parse_args ()  in

if command<>"mpAlle"  then raise (Arg.Bad command);

gib_xpm_aus (rgb_grau 1.0) outname (berechne gric puzzles)

