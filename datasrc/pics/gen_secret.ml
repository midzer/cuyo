(*
   Copyright 2011 by Mark Weyer
   Modified 2014 by Immanuel Halupczok

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
open Vektorgraphik
open Male_mit_aa

let zug (h::t) =
  let letzter,fastfertig = List.fold_left
    (function p,bisher -> function p' -> p',Strecke (p,p')::bisher)
    (h,[])
    t  in
  Strecke (letzter,h) :: fastfertig

let sorten_umrisse = [|
  zug [-0.4,-0.2; 0.4,0.0; -0.4,0.2];
  zug [-0.4,-0.1; 0.2,-0.1; 0.2,-0.2; 0.4,0.0; 0.2,0.2; 0.2,0.1; -0.4,0.1];
  zug [-0.4,-0.2; 0.0,0.0; -0.4,0.2] @
    zug [0.0,-0.2; 0.4,0.0; 0.0,0.2];
  zug [-0.4,-0.2; -0.3,-0.1; 0.3,-0.1; 0.4,0.0; 0.3,0.1; -0.3,0.1; -0.4,0.2];
  |]

let grasgrau_umrisse = [|
  zug [-0.4,-0.2; 0.4,-0.2; 0.4,0.2; -0.4,0.2];
  zug [-0.4,0.0; 0.0,-0.2; 0.4,0.0; 0.0,0.2];
  zug [-0.4,-0.2; 0.4,0.2; 0.4,-0.2; -0.4,0.2];
  [Spline ((-0.4,0.0),(-0.4,0.25),(0.4,0.25),(0.4,0.0));
    Spline ((0.4,0.0),(0.4,-0.25),(-0.4,-0.25),(-0.4,0.0))];
  |]

let sorten_farben = Array.map (fun (r,g,b) -> von_rgb (rgbrgb r g b)) [|
  1.0,0.75,0.0;
  0.0,1.0,0.5;
  1.0,0.5,0.5;
  0.5,0.5,1.0;
  |]

let grasgrau_farben = Array.map (fun (r,g,b) -> von_rgb (rgbrgb r g b)) [|
  0.4,0.0,0.9;
  0.2,0.6,0.0;
  0.6,0.3,0.0;
  0.2,0.2,0.5;
  |]

let schraffur teiler hoch =
  let fy = if hoch  then Helfer.id  else fun y -> 1.0-.y  in
  Helfer.list_for 0 teiler (fun i ->
    let t = float_of_int i /. float_of_int teiler  in
    Strecke ((0.0,fy (1.0-.t)), (t,fy 1.0))) @
  Helfer.list_for 1 teiler (fun i ->
    let t = float_of_int i /. float_of_int teiler  in
    Strecke ((t,fy 0.0), (1.0,fy (1.0-.t))))

let punktur teiler =
  let d = 1.0 /. float_of_int teiler  in
  let d' = d/.2.0  in
  List.concat (Helfer.list_for 1 teiler (fun i ->
    let x = (float_of_int i -. 0.75) *. d  in
    List.concat (Helfer.list_for 1 teiler (fun j ->
      let y = (float_of_int j -. 0.75) *. d  in
      [Strecke ((x,y),(x,y)); Strecke ((x+.d',y+.d'),(x+.d',y+.d'))]))))

let schraffuren = Array.map konvertiere_polygon [|
  [];
  schraffur 5 true;
  schraffur 5 false;
  punktur 6;
  |]

let dinge umriss richtung schraffur schraffurfarbe =
  let umriss = konvertiere_polygon (
    verschiebe_polygon (0.5) (0.5) (
    drehe_polygon (float_of_int (45*richtung))
    umriss))  in
  let rahmen = konvertiere_polygon [
    Strecke ((0.0,0.0),(1.0,0.0));
    Strecke ((1.0,0.0),(1.0,1.0));
    Strecke ((1.0,1.0),(0.0,1.0));
    Strecke ((0.0,1.0),(0.0,0.0));
    ]  in
  [
  Dicker_Strich (schraffurfarbe, 1.0/.32.0, [schraffur]);
  flaeche durchsichtig [rahmen;umriss];
  Strich (schwarz,[umriss]);
  ]

let bild umrisse farben rf schraffurfarbe =
  Graphik.kombiniere_bildchen 16 16
    (List.concat (Helfer.list_for 0 3 (fun i1 ->
      List.concat (Helfer.list_for 0 3 (fun i2 ->
        List.concat (Helfer.list_for 0 3 (fun i3 ->
          Helfer.list_for 0 3 (fun i4 ->
            4*i1+i2,
            4*i3+i4,
            male
              (erzeuge_vektorbild (dinge
                umrisse.(i1) (i3*rf) schraffuren.(i4) schraffurfarbe))
              (1.0/.32.0)
              (Graphik.monochrom farben.(i2) 1 1)))))))))

let sorten () = bild sorten_umrisse sorten_farben 2 schwarz
let grasgrau () = bild grasgrau_umrisse grasgrau_farben 1 (grau 0.8)

;;

let gric,command,outname = Gen_common.parse_args ()  in

let teil = Helfer.coprefix command 3  in

let bild = match teil with
| "Kind" -> sorten ()
| "GG" -> grasgrau ()  in

Graphik.gib_xpm_aus (rgb_grau 1.0) outname (Graphik.berechne gric bild)

