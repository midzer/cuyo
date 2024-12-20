(*
   Copyright 2008,2011 by Mark Weyer
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

let male breite hoehe bild =
  male bild (1.0/.32.0) (monochrom durchsichtig breite hoehe)

let raus gric name bild = gib_xpm_aus (rgb_grau 1.0) name (berechne gric bild)

let bogen (x,y) winkel laenge kruemmung =
  let cw,sw = cos winkel, sin winkel  in
  let pos = kruemmung > 0.0  in
  let w' = if pos  then winkel-.pi/.2.0  else winkel+.pi/.2.0  in
  Bogen ((x-.kruemmung*.sw,y+.kruemmung*.cw),
    (if pos  then kruemmung  else -.kruemmung),
    pos, w', w'+.laenge/.kruemmung)


let arm_dicke1 = 1.0/.30.0
let arm_dicke2 = 1.0/.45.0

let octopus (a0,a1,a2,a3,a4,a5,a6,a7) farbe1 farbe2 =
  let arm nummer kruemmung =
    let winkel = (float_of_int (nummer+2))*.pi/.4.0  in
    [match kruemmung with
    | None -> Strecke ((0.5,0.5),(0.5+.cos winkel,0.5+.sin winkel))
    | Some r -> bogen (0.5,0.5) (winkel-.1.0/.7.0/.r) (3.0/.7.0) r
    ]  in
  let arme = konvertiere_polygon
    ((arm 0 a0) @ (arm 1 a1) @ (arm 2 a2) @ (arm 3 a3) @
    (arm 4 a4) @ (arm 5 a5) @ (arm 6 a6) @ (arm 7 a7))  in
  let kopfrad = 1.0/.4.0  in
  let kopfh = kopfrad*.3.0/.4.0  in
  let halsy = 0.5-.kopfrad*.(2.0-.sqrt(3.0))  in
  let kopfy = halsy+.kopfh  in
  let kopf = konvertiere_polygon [
    Bogen ((0.5,kopfy), kopfrad, true, 0.0, pi);
    Strecke ((0.5-.kopfrad, kopfy), (0.5-.kopfrad, halsy));
    Bogen ((0.5, halsy+.kopfrad*.sqrt(3.0)), 2.0*.kopfrad,
      true, pi*.4.0/.3.0, pi*.5.0/.3.0);
    Strecke ((0.5+.kopfrad, halsy), (0.5+.kopfrad, kopfy))
  ]  in
  let blesse = konvertiere_polygon
    [Bogen ((0.5,kopfy), kopfrad*.3.0/.4.0, true,
      pi*.2.0/.5.0, pi*.3.0/.4.0)]  in
  let augerad = kopfrad/.3.0  in
  let augey = kopfy  in
  let augend = augerad*.3.0  in
  let puprad = kopfrad/.5.0  in
  let pupy = augey-.puprad/.2.0  in
  let augepup t =
    let x = 0.5+.augend*.t/.2.0  in
      [Kreis ((x,augey),augerad)],
      [Kreis ((x,pupy),puprad)]  in
  let auge1,pup1 = augepup (-1.0)  in
  let auge2,pup2 = augepup (1.0)  in
  let auge = konvertiere_polygon (auge1@auge2)  in
  let pup = konvertiere_polygon (pup1@pup2)  in
  male 1 1 (erzeuge_vektorbild [
      Dicker_Strich (farbe1, 1.0/.30.0, [arme]);
      Dicker_Strich (farbe2, 1.0/.45.0, [arme]);
      Strich (farbe1, [kopf]);
      Flaechen ([| farbe1; weiss; schwarz |], [
        kopf, 0, None;
        auge, 1, Some 0;
        pup, 2, Some 1;
      ]);
      Dicker_Strich (farbe2, kopfrad/.7.0, [blesse]);
    ])

let octopus (k0,k1,k2,k3,k4,k5,k6,k7) ad a0 a2 a4 a6 =
  octopus (
    (if a0  then None  else Some k0),
    (if ad  then None  else Some k1),
    (if a2  then None  else Some k2),
    (if ad  then None  else Some k3),
    (if a4  then None  else Some k4),
    (if ad  then None  else Some k5),
    (if a6  then None  else Some k6),
    (if ad  then None  else Some k7))

let schema_mitte farbe1 farbe2 =
  let raute = konvertiere_polygon [
    Strecke ((-0.5,0.5),(0.5,-0.5));
    Strecke ((0.5,-0.5),(1.5,0.5));
    Strecke ((1.5,0.5),(0.5,1.5));
    Strecke ((0.5,1.5),(-0.5,0.5));
  ]  in
  male 1 1 (erzeuge_vektorbild [
    Dicker_Strich (farbe1, arm_dicke1, [raute]);
    Dicker_Strich (farbe2, arm_dicke2, [raute]);
  ])
  
let octopi farbe1 farbe2 kruemmungen =
  let octopus = octopus kruemmungen  in
  kombiniere_bildchen 3 3
    (List.map (fun (x,y,b) -> (x,y,b farbe1 farbe2)) [
      0,0,octopus false true  true  false false;
      1,0,octopus true  false false true  true;
      2,0,octopus false false true  true  false;
      0,1,octopus true  false true  true  false;
      1,1,schema_mitte;
      2,1,octopus true  true  false false true;
      0,2,octopus false true  false false true;
      1,2,octopus true  true  true  false false;
      2,2,octopus false false false true  true;
    ])

let octopi_daten = [|
    rgbrgb 0.79 0.06 0.79, rgbrgb 0.95 0.37 0.96,
      ( 3.0, -1.0,  0.5,  1.5, -0.3, -2.0,  0.4,  0.7);
    rgb_grau 0.2, rgb_grau 0.6,
      (-2.0, -1.5, -1.5,  0.8,  1.0, -1.0,  0.6, -1.0);
    rgbrgb 0.2 0.2 0.8, rgbrgb 0.5 0.5 1.0,
      (-2.5,  1.0,  0.7, -0.5, -0.5,  0.6, -1.0,  1.5);
    rgbrgb 0.6 0.61 0.1, rgbrgb 0.8 0.83 0.3,
      ( 3.0,  0.7,  1.0, -0.3,  0.8,  0.3, -2.0, -1.0);
    rgbrgb 0.8 0.5 0.1, rgbrgb 0.9 0.7 0.4,
      ( 2.0,  1.5, -0.3, -1.0, -2.0,  0.5,  1.0,  1.0);
  |]

let octopi gric command outname =
  let nummer = int_of_string (suffix command 1) - 1  in
  let farbe1,farbe2,kruemmungen = octopi_daten.(nummer)  in
  raus gric outname (octopi (von_rgb farbe1) (von_rgb farbe2) kruemmungen)



let welle w d x y = cos ((x*.cos w +. y*.sin w)/.d)

let anemone w1 w2 =
  let num = 50  in
  let g = (sqrt 5.0 -. 1.0)*.pi  in
  let num_ = float_of_int num  in
  let farbe1 = von_rgb (rgbrgb 1.0 0.7 0.7)  in
  let farbe2 = von_rgb (rgbrgb 1.0 0.3 0.7)  in
  let farbe3 = von_rgb (rgbrgb 1.0 1.0 0.7)  in
  let farbe4 = von_rgb (rgbrgb 0.8 0.8 0.2)  in
  let faeden = Array.init num
    (fun i ->
      let i = float_of_int i  in
      let w = g *. i  in
      let r = sqrt (i/.num_)/.4.0  in
      (r*.cos w, r*.sin w))  in
  Array.sort
    (fun (x1,y1) -> fun (x2,y2) -> Pervasives.compare y2 y1)
    faeden;
  male 1 1 (erzeuge_vektorbild (List.concat (List.map
    (fun (x,y) ->
      let r2 = x*.x +. y*.y  in
      let mitte = 31.0*.r2 < 1.0  in
      let strich = konvertiere_polygon
        [bogen (0.5+.x, 0.25+.y/.2.0) (pi/.2.0 -. x)
          ((if mitte  then 0.3  else 0.4)
            -. 3.0*.r2 +. (welle w1 0.1 x y)/.29.0 +. y/.3.0)
          (0.4/.((welle w2 0.1 x y)/.2.0 -. 5.0*.x))]  in
      [Dicker_Strich ((if mitte  then farbe4  else farbe2),
          1.0/.29.0, [strich]);
        Strich ((if mitte  then farbe3  else farbe1), [strich]);
      ])
    (Array.to_list faeden))))

let anemonen gric outname =
  raus gric outname (kombiniere_bildchen 4 1
    (List.map (fun (x,w1,w2) -> (x,0,anemone w1 w2)) [
      0, 4.0, 1.0;
      1, 8.0, 6.0;
      2, 7.0, 5.0;
      3, 2.0, 3.0;
    ]))


let fisch gric outname =
  let blau1 = von_rgb (rgbrgb 0.45 0.55 1.0)  in
  let blau2 = von_rgb (rgbrgb 0.5 0.7 1.0)  in
  let blau3 = von_rgb (rgbrgb 0.3 0.4 0.8)  in
  let koerper_p = (0.55,0.5)  in
  let koerper = konvertiere_polygon [Kreis (koerper_p,0.35)]  in
  let auge_p = (0.75,0.6)  in
  let dreieck p1 p2 p3 = konvertiere_polygon
    [Strecke (p1,p2); Strecke (p2,p3); Strecke (p3,p1)]  in
  let ruecken = dreieck (0.5,0.9) (0.6,0.8) (0.5,0.8)  in
  let schwanz = dreieck (0.2,0.5) (0.1,0.7) (0.1,0.3)  in
  let bein = dreieck (0.35,0.25) (0.35,0.15) (0.4,0.2)  in
  let arm = dreieck (0.7,0.25) (0.75,0.15) (0.75,0.3)  in
  let flosse umriss =
    [Strich (blau3,[umriss]); Flaechen ([| blau3 |],[umriss,0,None])]  in
  let fisch =
    (flosse ruecken) @ (flosse schwanz) @ (flosse bein) @
    [
    Strich (blau1,[koerper]);
    Flaechen ([| blau1; weiss; schwarz |], [
      koerper,0,None;
      konvertiere_polygon [Kreis (auge_p,0.09)], 1, Some 0;
      konvertiere_polygon [Kreis (auge_p,0.03)], 2, Some 1;
      ]);
    Dicker_Strich (blau2, 0.04, [konvertiere_polygon
      [Bogen (koerper_p,0.25,true,pi*.2.0/.5.0, pi*.6.0/.7.0)]])
    ] @
    (flosse arm)  in
  raus gric outname (male 1 1 (erzeuge_vektorbild fisch))


;;

let gric,command,outname = Gen_common.parse_args ()  in

match command with
| "moAnemone" -> anemonen gric outname
| "moFisch" -> fisch gric outname
| _ -> octopi gric command outname

