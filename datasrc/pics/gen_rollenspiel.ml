(*
   Copyright 2006 by Mark Weyer
   Maintenance modifications 2007,2010,2011 by the cuyo developers

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


let rand = 3.0/.64.0
let kantenrad = 1.0/.5.0
let punktd = 2.0/.9.0
let punktrad = 1.0/.15.0

let rand' = rand+.kantenrad
let punktp = 0.5-.punktd
let punktp' = 0.5+.punktd

let grau = rgbrgb 0.9 0.9 1.0
let normal = rgbrgb 1.0 1.0 0.8
let gras = rgbrgb 1.0 0.9 0.9

let wuerfel farbe n =
  let punkte =
    (if n mod 2 = 1  then [0.5,0.5]  else []) @
    (if n >= 3  then [punktp,punktp; punktp',punktp']  else []) @
    (if n-2*(n mod 2) >= 2  then [punktp',punktp; punktp,punktp']  else []) @
    (if n >= 6  then [punktp,0.5; punktp',0.5]  else []) @
    (if n >= 8  then [0.5,punktp; 0.5,punktp']  else [])  in
  let punkte = konvertiere_polygon
    (List.map (fun p -> Kreis (p,punktrad)) punkte)  in
  let aussen = konvertiere_polygon
    [Strecke ((rand',rand),(1.0-.rand',rand));
    Bogen ((1.0-.rand',rand'),kantenrad,true,1.5*.pi,0.0);
    Strecke ((1.0-.rand,rand'),(1.0-.rand,1.0-.rand'));
    Bogen ((1.0-.rand',1.0-.rand'),kantenrad,true,0.0,0.5*.pi);
    Strecke ((1.0-.rand',1.0-.rand),(rand',1.0-.rand));
    Bogen ((rand',1.0-.rand'),kantenrad,true,0.5*.pi,pi);
    Strecke ((rand,1.0-.rand'),(rand,rand'));
    Bogen ((rand',rand'),kantenrad,true,pi,1.5*.pi);]  in
  male
    (erzeuge_vektorbild
      [Flaechen ([|von_rgb farbe; schwarz|], [aussen,0,None; punkte,1,Some 0]);
      Strich (schwarz, [aussen; punkte])])
    (1.0/.32.0)
    (monochrom durchsichtig 1 1)

let wuerfel = kombiniere_bildchen 2 4
  [(0,3,wuerfel grau 0);
  (1,3,wuerfel normal 1); (0,2,wuerfel normal 2); (1,2,wuerfel normal 3);
  (0,1,wuerfel normal 4); (1,1,wuerfel normal 5); (0,0,wuerfel normal 6);
  (1,0,wuerfel gras 9)]



;;

let gric,command,outname = Gen_common.parse_args ()  in

if command<>"mrpAlle"  then raise (Arg.Bad command);

gib_xpm_aus (rgb_grau 1.0) outname (berechne gric wuerfel)

