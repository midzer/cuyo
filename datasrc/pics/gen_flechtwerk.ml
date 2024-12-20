(*
   Copyright 2011 by Mark Weyer

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

exception Zu_nah

open Helfer
open Farbe
open Vektorgraphik
open Male_mit_aa

let dicke = 1.0/.16.0
let maxd = 1e-6

let gradient_richtung feld p fp =
  let d = if fp<maxd
  then fp/.2.0
  else if fp>1.0-.maxd
    then (1.0-.fp)/.2.0
    else maxd  in
  let x,y = p  in
  let ddx = (feld (x+.d, y) -. feld (x-.d, y)) /. d  in
  let ddy = (feld (x, y+.d) -. feld (x, y-.d)) /. d  in
  atan2 ddy ddx

let flecht f linien =
  let _,_,drin = male (erzeuge_vektorbild [Flaechen (
      [| rot; gruen |],
      [konvertiere_polygon (List.concat linien), 0, Some 1;
        konvertiere_polygon [Kreis ((0.5,0.5),10.0)], 0, None])])
    dicke
    (Graphik.monochrom schwarz 1 1)  in
  let drin p =
    let farbe = drin p  in
    nur_rot farbe > nur_gruen farbe  in
  let nah = List.map (fun linie ->
      let _,_,nah = male
        (erzeuge_vektorbild [Strich (blau,[konvertiere_polygon
          (verschiebe_polygon 1.0 1.0 linie)])])
        dicke
        (Graphik.monochrom schwarz 3 3)  in
      fun (x,y) -> nur_blau (nah (x+.1.0,y+.1.0)))
    linien  in
  1,1,fun p ->
    match List.filter (fun (naehe,nah) -> naehe>0.0)
      (List.map (fun nah -> nah p, nah) nah) with
    | [] -> f 0.0 None
    | [naehe,_] -> f naehe None
    | naehen ->
      let naehen = List.sort
        (fun (naehe1,_) -> fun (naehe2,_) -> Pervasives.compare naehe2 naehe1)
        naehen  in
      let (naehe1,nah1) :: (naehe2,nah2) :: rest = naehen  in
      let dritte = rest<>[]  in
      let winkel = (gradient_richtung nah1 p naehe1)
        -. (gradient_richtung nah2 p naehe2)  in
      let winkel = winkel /. (2.0*.pi)  in
      let winkel = winkel -. floor winkel  in
      if xor (winkel>=0.5) (drin p)
      then f naehe1 (Some (naehe2,dritte))
      else f naehe2 (Some (naehe1,dritte))

let test f linien = male (erzeuge_vektorbild
    [Strich (schwarz,[konvertiere_polygon (List.concat linien)])])
  dicke
  (Graphik.monochrom durchsichtig 1 1)


let stift = 0.5
let luecke = 1.0-.stift

let f1 naehe1 naehe2 =
  let dritter = match naehe2  with
  | None -> false
  | Some (_,dritter) -> dritter  in
  let d = (1.0-.naehe1)/.stift  in
  if dritter || d>=1.0  then durchsichtig  else grau d


let leer = []

let e = 1.0/.(6.0+.12.0*.sqrt 2.0)
let e' = e*.sqrt 2.0

let al1 = 1.0-.e
let al2 = 0.5-.3.0*.e'
let a1 = al1,al2
let a2 = al2,al1
let a3 = -.al2,al1
let a4 = -.al1,al2
let a5 = -.al1,-.al2
let a6 = -.al2,-.al1
let a7 = al2,-.al1
let a8 = al1,-.al2
let achteck = [
    Strecke (a1,a2);
    Strecke (a2,a3);
    Strecke (a3,a4);
    Strecke (a4,a5);
    Strecke (a5,a6);
    Strecke (a6,a7);
    Strecke (a7,a8);
    Strecke (a8,a1);
  ]

let rl = 1.0-.e'
let r1 = rl,0.0
let r2 = 0.0,rl
let r3 = -.rl,0.0
let r4 = 0.0,-.rl
let raute = [
    Strecke (r1,r2);
    Strecke (r2,r3);
    Strecke (r3,r4);
    Strecke (r4,r1);
  ]

let bl1 = 2.0*.e+.2.0*.e'
let bl2 = 0.5+.e+.3.0*.e'
let bl3 = e
let bl4 = 0.5+.e'
let b1 = bl2,bl1
let b2 = bl4,bl3
let b3 = bl3,bl4
let b4 = bl1,bl2
let b5 = -.bl1,bl2
let b6 = -.bl3,bl4
let b7 = -.bl4,bl3
let b8 = -.bl2,bl1
let b9 = -.bl2,-.bl1
let b10 = -.bl4,-.bl3
let b11 = -.bl3,-.bl4
let b12 = -.bl1,-.bl2
let b13 = bl1,-.bl2
let b14 = bl3,-.bl4
let b15 = bl4,-.bl3
let b16 = bl2,-.bl1
let burg = [
    Strecke (r1,b1);
    Strecke (b1,b2);
    Strecke (b2,b3);
    Strecke (b3,b4);
    Strecke (b4,r2);
    Strecke (r2,b5);
    Strecke (b5,b6);
    Strecke (b6,b7);
    Strecke (b7,b8);
    Strecke (b8,r3);
    Strecke (r3,b9);
    Strecke (b9,b10);
    Strecke (b10,b11);
    Strecke (b11,b12);
    Strecke (b12,r4);
    Strecke (r4,b13);
    Strecke (b13,b14);
    Strecke (b14,b15);
    Strecke (b15,b16);
    Strecke (b16,r1);
  ]

let gl = 0.5-.e-.3.0*.e'
let g1 = gl,gl
let g2 = -.gl,gl
let g3 = -.gl,-.gl
let g4 = gl,-.gl
let grau = [
    Strecke (g1,g2);
    Strecke (g2,g3);
    Strecke (g3,g4);
    Strecke (g4,g1);
  ]

let grl1 = 6.0*.e
let grl2 = 0.1
let grl3 = 0.2
let gras = [Kreis ((0.0,0.0),grl1)]
let grasverbind = [
    Spline ((0.0,grl1),(-.grl3,grl1),(-0.5+.grl3,grl2),(-0.5,grl2));
    Bogen ((-0.5,0.0),grl2,true,0.5*.pi,1.5*.pi);
    Spline ((-0.5,-.grl2),(-0.5+.grl3,-.grl2),(-.grl3,-.grl1),(0.0,-.grl1));
    Spline ((0.0,-.grl1),(grl3,-.grl1),(0.5-.grl3,-.grl2),(0.5,-.grl2));
    Bogen ((0.5,0.0),grl2,true,-0.5*.pi,0.5*.pi);
    Spline ((0.5,grl2),(0.5-.grl3,grl2),(grl3,grl1),(0.0,grl1));
  ]

let kombiniere linksrechts obenunten diagonal mitte b h f =
  let alr = List.length linksrechts  in
  let aou = List.length obenunten  in
  let ad = List.length diagonal  in
  let am = List.length mitte  in
  Graphik.kombiniere_bildchen b h (List.concat
    (list_for 0 (h-1) (fun j -> list_for 0 (b-1) (fun i -> i,j,
      let n = (h-1-j)*b+i  in
      let n,lr = n/alr, List.nth linksrechts (n mod alr)  in
      let n,ou = n/aou, List.nth obenunten (n mod aou)  in
      let n,d = n/ad, List.nth diagonal (n mod ad)  in
      let m = List.nth mitte n  in
      flecht f [
        verschiebe_polygon (-0.5) 0.5 lr @ verschiebe_polygon 1.5 0.5 lr;
        verschiebe_polygon 0.5 (-0.5) ou @ verschiebe_polygon 0.5 1.5 ou;
        verschiebe_polygon (-0.5) (-0.5) d @ verschiebe_polygon 1.5 1.5 d @
        verschiebe_polygon (-0.5) 1.5 d @ verschiebe_polygon 1.5 (-0.5) d;
        verschiebe_polygon 0.5 0.5 m;
      ]))))

let alles = kombiniere
  [leer; achteck; raute; burg]
  [leer; achteck; raute; burg]
  [leer; achteck]
  [leer; achteck; raute; burg; grau; gras]
  16  12

let gras = kombiniere
  [leer]
  [leer; achteck; raute; burg]
  [leer; achteck]
  [grasverbind]
  4  2

let klein = kombiniere
  [leer]
  [leer]
  [leer]
  (List.map (skaliere_polygon 0.5) [achteck; raute; burg])
  3 1

;;

let gric,command,outname = Gen_common.parse_args ()  in

let bild = match command with
| "mflAlles" -> alles f1
| "mflGrasV" -> gras f1
| "mflKlein" -> klein f1  in

Graphik.gib_xpm_aus (rgb_grau 1.0) outname (Graphik.berechne gric bild)

