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

open Helfer
open Farbe
open Graphik
open Vektorgraphik
open Male_mit_aa


let regenbogenkreis radius farben =
  let n = List.length farben  in
  let alpha i rechts =
    let alpha = asin (1.0-.2.0*.(float_of_int i)/.(float_of_int n))  in
    if rechts  then alpha  else pi-.alpha  in
  let pos i rechts =
    let alpha = alpha i rechts  in
    radius*.cos alpha, radius*.sin alpha  in
  let grenzen = List.map
    (fun (p,i,j) -> konvertiere_polygon p,i,j)
    (List.concat (list_for 0 (n-1) (fun i ->
      if n=1
      then [[Kreis ((0.0,0.0),radius)], 0, None]
      else if i=0
        then [
          [Bogen ((0.0,0.0),radius,true,alpha 1 true,alpha 1 false)], 0, None;
          [Strecke (pos 1 false, pos 1 true)], 0, Some 1]
        else if i=n-1
          then [
            [Bogen ((0.0,0.0),radius,true,alpha (n-1) false,alpha (n-1) true)],
              n-1, None]
          else [
            [Bogen ((0.0,0.0),radius,true,alpha (i+1) true,alpha i true);
              Bogen ((0.0,0.0),radius,true,alpha i false, alpha (i+1) false);
              ], i, None;
            [Strecke (pos (i+1) false, pos (i+1) true)], i, Some (i+1)])))  in
  let rand = [konvertiere_polygon [Kreis ((0.0,0.0),radius)]]  in
  [
  Flaechen (Array.of_list farben, grenzen);
  Strich (schwarz,rand);
  ]

let morph neu =
  let grau = lies_xpm "mbmGrau.xpm"  in
  let grau =
    skaliere_dinge 0.7
    (verschiebe_dinge (-0.5) (-0.5)
    (skaliere_dinge (1.0/.32.0)
    (pixel_zu_dingen (Some durchsichtig) grau)))  in
  let x = 0.1  in
  verschiebe_dinge 0.5 0.5 (
    (verschiebe_dinge (-.x) 0.0 grau) @
    (verschiebe_dinge x 0.0 neu))

let graugras = "GrauGras", (von_rgb (rgbrgb 0.0 0.0 1.0),
  let gras_schema = lies_xpm "mbmGras.xpm"  in
  let gras = kleb false
    (kleb true
      (ausschnitt 64 0 80 16 gras_schema)
      (ausschnitt 80 64 96 80 gras_schema))
    (kleb true
      (ausschnitt 0 16 16 32 gras_schema)
      (ausschnitt 16 80 32 96 gras_schema))  in
  let gras =
    skaliere_dinge 0.7
    (verschiebe_dinge (-0.5) (-0.5)
    (skaliere_dinge (1.0/.32.0)
    (pixel_zu_dingen (Some durchsichtig) gras)))  in
  morph gras)

let leben = "Leben", (0.5, 0.5, 0.5,
  let rumpfbreite = 0.15  in
  let rumpfhoehe = 0.35  in
  let fluegelbreite = 0.125  in
  let fluegellaengeinnen = 0.15  in
  let fluegellaengeaussen = 0.075  in
  let triebwerklaenge = 0.25  in
  let triebwerkversatz = 0.1  in
  let x1 = rumpfbreite/.2.0  in
  let x2 = x1+.fluegelbreite  in
  let l = triebwerkversatz+.rumpfhoehe  in
  let y1 = -.l/.2.0  in
  let y2 = y1+.triebwerkversatz  in
  let y3 = y1+.fluegellaengeaussen  in
  let y4 = y2+.fluegellaengeinnen  in
  let y5 = y1+.triebwerklaenge  in
  let y6 = l/.2.0-.rumpfbreite  in
  [
  Strecke ((-.x2,y1),(-.x2,y5));
  Strecke ((x2,y1),(x2,y5));
  Strecke ((-.x2,y1),(-.x1,y2));
  Strecke ((x2,y1),(x1,y2));
  Strecke ((-.x2,y3),(-.x1,y4));
  Strecke ((x2,y3),(x1,y4));
  Strecke ((-.x1,y2),(-.x1,y6));
  Strecke ((x1,y2),(x1,y6));
  Strecke ((-.x1,y2),(x1,y2));
  Bogen ((x1,y6),rumpfbreite,true,pi*.2.0/.3.0,pi);
  Bogen ((-.x1,y6),rumpfbreite,true,0.0,pi/.3.0);
  ])

let ketten = "Ketten", (1.0, 0.0, 0.0,
  let radius = 0.05  in
  let abstand = 0.05  in
  let alpha = asin (abstand/.radius)  in
  let laenge = 0.17  in
  let xv1 = laenge*.0.5-.radius  in
  let xv2 = laenge*.0.5+.abstand+.radius  in
  let xv3 = laenge*.1.5+.abstand-.radius  in
  let xh1 = abstand/.2.0  in
  let xh2 = abstand/.2.0+.laenge  in
  let vglied x1 x2 zu1 zu2 = [
    Strecke ((x1,radius),(x2,radius));
    Strecke ((x1,-.radius),(x2,-.radius));
    ] @ (if zu1
    then [Bogen ((x1,0.0),radius,true,pi*.0.5,pi*.1.5)]
    else [
      Bogen ((x1,0.0),radius,true,pi*.0.5,pi-.alpha);
      Bogen ((x1,0.0),radius,true,pi+.alpha,pi*.1.5);
      ])
    @ (if zu2
    then [Bogen ((x2,0.0),radius,true,-.pi*.0.5,pi*.0.5)]
    else [
      Bogen ((x2,0.0),radius,true,alpha,pi*.0.5);
      Bogen ((x2,0.0),radius,true,-.pi*.0.5,-.alpha);
      ])  in
  (vglied (-.xv3) (-.xv2) true false) @
  (vglied (-.xv1) xv1 false false) @
  (vglied xv2 xv3 false true) @
  [
  Strecke ((xh1,0.0),(xh2,0.0));
  Strecke ((-.xh1,0.0),(-.xh2,0.0));
  ])

let verbind_2 =
  let radius = 0.125  in
  let abstand = 0.15  in
  let y = radius+.abstand/.2.0  in
  [
  Kreis ((0.0,y),radius);
  Kreis ((0.0,-.y),radius);
  Strecke ((0.0,abstand/.2.0),(0.0,-.abstand/.2.0));
  ]

let verbind_3 =
  let radius = 0.1  in
  let abstand = 0.1  in
  let xy = radius+.abstand/.2.0  in
  [
  Kreis ((-.xy,-.xy),radius);
  Kreis ((xy,-.xy),radius);
  Strecke ((radius-.xy,-.xy),(xy-.radius,-.xy));
  Kreis ((xy,xy),radius);
  Strecke ((xy,radius-.xy),(xy,xy-.radius));
  ]

let verbind_4 =
  let radius = 0.07  in
  let abstand = 0.08  in
  let x = 2.0*.radius+.abstand  in
  let y = radius+.abstand/.2.0  in
  [
  Kreis ((-.x,-.y),radius);
  Strecke ((radius-.x,-.y),(-.radius,-.y));
  Kreis ((0.0,-.y),radius);
  Strecke ((0.0,abstand/.2.0),(0.0,-.abstand/.2.0));
  Kreis ((0.0,y),radius);
  Strecke ((radius,y),(x-.radius,y));
  Kreis ((x,y),radius);
  ]

let verbind_5 =
  let radius = 0.055  in
  let abstand = 0.07  in
  let xy = 2.0*.radius+.abstand  in
  [
  Kreis ((0.0,0.0),radius);
  Kreis ((-.xy,0.0),radius);
  Strecke ((radius-.xy,0.0),(-.radius,0.0));
  Kreis ((xy,0.0),radius);
  Strecke ((xy-.radius,0.0),(radius,0.0));
  Kreis ((0.0,xy),radius);
  Strecke ((0.0,xy-.radius),(0.0,radius));
  Kreis ((xy,-.xy),radius);
  Strecke ((xy,radius-.xy),(xy,-.radius));
  ]

let kurz = "Kurz", (0.5, 1.0, 0.0, verbind_2)
let lang = "Lang", (1.0, 0.0, 0.5, verbind_4)

let langsam = "Langsam", (0.0, 1.0, 0.5,
  let radius = 0.25  in
  [
  Bogen ((0.0,0.0),radius,true,0.0,pi);
  Strecke ((-.radius,0.0),(radius,0.0));
  Strecke ((0.0,-.radius),(-.radius,0.0));
  Strecke ((0.0,-.radius),(-.radius/.3.0,0.0));
  Strecke ((0.0,-.radius),(radius/.3.0,0.0));
  Strecke ((0.0,-.radius),(radius,0.0));
  ])

let verbind_radius = 0.2

let minus = "Minus", (0.5, 0.0, 0.5,
  [Strecke ((-.verbind_radius,0.0),(verbind_radius,0.0));])

let octi = "Octi", (0.0, 1.0, 0.0,
  [
  Strecke ((-.verbind_radius,0.0),(verbind_radius,0.0));
  Strecke ((-.verbind_radius,-.verbind_radius),(verbind_radius,verbind_radius));
  Strecke ((0.0,-.verbind_radius),(0.0,verbind_radius));
  Strecke ((-.verbind_radius,verbind_radius),(verbind_radius,-.verbind_radius));
  ])

let punkte = "Punkte", (1.0, 0.5, 0.0,
  let hoehe = 0.18  in
  let breite = 0.08  in
  let abstand = 0.04  in
  let null x =
    let y = hoehe-.breite  in
    [
    Bogen ((x,y),breite,true,0.0,pi);
    Strecke ((x-.breite,y),(x-.breite,-.y));
    Bogen ((x,-.y),breite,true,pi,2.0*.pi);
    Strecke ((x+.breite,-.y),(x+.breite,y));
    ]  in
  let zwei x =
    let y = hoehe-.breite  in
    let alpha = asin (2.0*.breite/.(hoehe+.y))  in
    [
    Bogen ((x,y),breite,true,-.alpha,pi);
    Strecke ((x-.breite,-.hoehe),(x+.breite*.cos alpha,y-.breite*.sin alpha));
    Strecke ((x-.breite,-.hoehe),(x+.breite,-.hoehe));
    ]  in
  (zwei (-.2.0*.breite-.abstand)) @ (null 0.0) @ (null (2.0*.breite+.abstand)))

let raketen = "Raketen", (0.0, 0.5, 1.0,
  let breite = 0.05  in
  let hoehe = 0.15  in
  let fluegelbreite = 0.05  in
  let abstand = 0.1  in
  let x = breite+.fluegelbreite+.abstand/.2.0  in
  let rakete = [
    Bogen ((-.breite,-.hoehe-.fluegelbreite),fluegelbreite,true,0.5*.pi,pi);
    Bogen ((breite,-.hoehe-.fluegelbreite),fluegelbreite,true,0.0,0.5*.pi);
    Bogen ((fluegelbreite-.breite,-.hoehe-.fluegelbreite),2.0*.fluegelbreite,
      true,pi*.2.0/.3.0,pi);
    Bogen ((breite-.fluegelbreite,-.hoehe-.fluegelbreite),2.0*.fluegelbreite,
      true,0.0,pi/.3.0);
    Strecke ((-.breite,-.hoehe),(breite,-.hoehe));
    Strecke ((-.breite,-.hoehe),(-.breite,hoehe));
    Strecke ((breite,-.hoehe),(breite,hoehe));
    Strecke ((-.breite,hoehe),(breite,hoehe));
    Bogen ((breite,hoehe),2.0*.breite,true,pi*.2.0/.3.0,pi);
    Bogen ((-.breite,hoehe),2.0*.breite,true,0.0,pi/.3.0);
    ]  in
  (verschiebe_polygon (-.x) 0.0 rakete) @ (verschiebe_polygon x 0.0 rakete))

let schnell = "Schnell", (1.0, 0.25, 0.0,       (* Gewicht *)
  let breite_unten = 0.4  in
  let breite_oben = 0.3  in
  let hoehe = 0.3  in
  let griff_radius = 0.05  in
  let d = griff_radius *. sqrt 0.5  in
  let h = hoehe +. griff_radius +. d  in
  let y1 = -0.5 *. h  in
  let y2 = y1+.hoehe  in
  let x1 = 2.0*.d  in
  let p0,p5 = (-.x1,y2),(x1,y2)  in
  let p1,p4 = (-.breite_oben/.2.0,y2), (breite_oben/.2.0,y2)  in
  let p2,p3 = (-.breite_unten/.2.0,y1), (breite_unten/.2.0,y1)  in
  [
  Strecke (p0,p1);
  Strecke (p1,p2);
  Strecke (p2,p3);
  Strecke (p3,p4);
  Strecke (p4,p5);
  Bogen ((x1,y2+.griff_radius),griff_radius,false,pi*.1.5,pi*.0.75);
  Strecke ((x1-.d,y2+.griff_radius+.d),(d-.x1,y2+.griff_radius+.d));
  Bogen ((-.x1,y2+.griff_radius),griff_radius,false,pi*.2.25,pi*.1.5);
  ])

let schnell = "Schnell", (1.0, 0.25, 0.0,       (* Streifen *)
  let radius = 0.18  in
  let abstand = 0.1  in
  let laenge = 0.15  in
  let abstand_seite = abstand  in
  let abstand_aussen = sqrt
     ((radius+.abstand)*.(radius+.abstand) -. abstand_seite*.abstand_seite)  in
  let y = radius-.(laenge+.2.0*.radius+.abstand)/.2.0  in
  [
  Kreis ((0.0,y),radius);
  Strecke ((-.abstand_seite,y+.abstand_aussen),
    (-.abstand_seite,y+.abstand_aussen+.laenge));
  Strecke ((0.0,y+.radius+.abstand),(0.0,y+.radius+.abstand+.laenge));
  Strecke ((abstand_seite,y+.abstand_aussen),
    (abstand_seite,y+.abstand_aussen+.laenge));
  ])

let schnell = "Schnell", (1.0, 0.25, 0.0,       (* Nachhall *)
  let radius = 0.15  in
  let anzahl = 3  in
  let abstand = 0.1  in
  let winkel = pi/.2.0  in
  let y = radius-.(2.0*.radius +. float_of_int anzahl*.abstand)/.2.0  in
  Kreis ((0.0,y),radius) ::
  list_for 1 anzahl (fun i ->
    Bogen ((0.0,y+.float_of_int i*.abstand),radius,true,
      (pi-.winkel)/.2.0,(pi+.winkel)/.2.0)))

let ununterscheidbar = "Ununterscheidbar", (0.0, 0.0, 0.0, [])

let verschwind = "Verschwind", (1.0, 1.0, 0.0,
  let anzahl = 7  in
  let anzf = float_of_int anzahl  in
  list_for 1 anzahl (fun i ->
    let i_f = float_of_int i  in
    Bogen ((0.0,0.0),0.25,true,
      2.0*.pi*.i_f/.anzf, 2.0*.pi*.(i_f+.0.5)/.anzf)))

let strichdinge = List.map
  (fun (name,(r,g,b,icon)) -> name,
    (von_rgb (rgbrgb r g b),
    let icon = [konvertiere_polygon (verschiebe_polygon 0.5 0.5 icon)]  in
    [
    Dicker_Strich (weiss,1.5/.32.0,icon);
    Strich (schwarz,icon)]))
  [
  raketen;
  langsam;
  octi;
  kurz;
  verschwind;
  punkte;
  schnell;
  ketten;
  lang;
  minus;
  leben;
  ununterscheidbar;
  ]

let graujoker =
  let farbe = von_rgb (rgbrgb 0.5 0.0 1.0)  in
  let farben = farbe::List.map fst (List.map snd (graugras::strichdinge))  in
  "GrauJoker",(farbe, morph (regenbogenkreis 0.2 farben))

let dinge = graujoker::graugras::strichdinge


let radius = 0.4
let octirad = 0.07
let coradius = sqrt 0.5 -. radius
let octi_p = coradius/.3.0

let schema farbe icon =
  let octi x y = [Kreis ((x,y),octirad)]  in
  let rand = konvertiere_polygon ([
    Bogen ((0.5,3.5),radius,true,0.75*.pi,1.75*.pi);
    Bogen ((1.0,3.0),coradius,false,0.75*.pi,0.25*.pi);
    Bogen ((1.5,3.5),radius,true,1.25*.pi,2.25*.pi);
    Bogen ((2.0,4.0),coradius,false,1.25*.pi,0.75*.pi);
    Bogen ((1.5,4.5),radius,true,1.75*.pi,0.75*.pi);
    Bogen ((1.0,5.0),coradius,false,1.75*.pi,1.25*.pi);
    Bogen ((0.5,4.5),radius,true,0.25*.pi,1.25*.pi);
    Bogen ((0.0,4.0),coradius,false,0.25*.pi,-.0.25*.pi);
    Kreis ((1.0,4.0),coradius);
    Kreis ((0.5,0.5),radius);
    Kreis ((0.5,1.5),radius);
    Kreis ((1.5,0.5),radius);
    Kreis ((1.5,1.5),radius);
    Kreis ((1.5,2.5),radius);
    ]
    @ (octi octi_p (3.0-.octi_p))
    @ (octi octi_p (2.0+.octi_p))
    @ (octi (1.0-.octi_p) (3.0-.octi_p))
    @ (octi (1.0-.octi_p) (2.0+.octi_p)))  in
  let icon_ = verschiebe_dinge 1.0 2.0 icon  in
  let icon = icon @ (verschiebe_dinge 1.0 0.0 icon)  in
  let icon = icon @ (verschiebe_dinge 0.0 1.0 icon)  in
  let icon = icon @ (verschiebe_dinge 0.0 3.0 icon)  in
  let loesch x y i j =
    let alpha = pi*.(float_of_int (2*i+1))/.16.0  in
    let beta = pi*.(float_of_int (2*j-1))/.16.0  in
    let radius = 0.5  in
    [
    Bogen ((x,y),radius,true,alpha,beta);
    Strecke ((x+.radius*.cos beta, y+.radius*.sin beta),
      (x-.radius*.cos beta, y-.radius*.sin beta));
    Bogen ((x,y),radius,false, beta+.pi, alpha+.pi);
    Strecke ((x-.radius*.cos alpha, y-.radius*.sin alpha),
      (x+.radius*.cos alpha, y+.radius*.sin alpha));
    ]  in
  let kreuz x y i = (loesch x y i (i+4)) @ (loesch x y (i+4) (i+8))  in
  let loesch = konvertiere_polygon (List.concat [
    kreuz 1.5 2.5 2;
    loesch 0.5 1.5 4 12;
    loesch 1.5 1.5 0 8;
    kreuz 0.5 0.5 3;
    kreuz 1.5 0.5 1;
    ])  in
  [
    flaeche farbe [rand];
    Strich (weiss,[rand]);
    ]
    @ icon_ @ icon @ [
    flaeche durchsichtig [loesch];
    ]

let uhr_breite = 4
let uhr_hoehe = 5
let uhr_rad = 0.25

let uhr (farbe,icon) =
  let uhr_for f = List.concat (list_for 0 (uhr_hoehe-1) (fun i ->
    list_for 0 (uhr_breite-1) (fun j ->
      f i j ((uhr_hoehe-1-i)*uhr_breite+j))))  in
  let rand = [konvertiere_polygon (uhr_for (fun i -> fun j -> fun k ->
    Kreis ((0.5+.float_of_int j, 0.5+.float_of_int i),uhr_rad)))]  in
  let icon = verschiebe_dinge 0.5 0.5
    (skaliere_dinge (uhr_rad/.radius)
    (verschiebe_dinge (-.0.5) (-.0.5) icon))  in
  let icons = List.concat (uhr_for (fun i -> fun j -> fun k ->
    verschiebe_dinge (float_of_int j) (float_of_int i) icon))  in
  let loesch = konvertiere_polygon (List.concat
    (uhr_for (fun i -> fun j -> fun k ->
      let winkel = pi *. (0.5 +. 2.0*.
        (float_of_int k)/.(float_of_int (uhr_breite*uhr_hoehe)))  in
      let x = float_of_int j +. 0.5  in
      let y = float_of_int i +. 0.5  in
      [
        Bogen ((x,y),0.5,true,0.5*.pi,winkel);
        Strecke ((x+.0.5*.cos winkel,y+.0.5*.sin winkel),(x,y));
        Strecke ((x,y),(x,y+.0.5))])))  in
  [
  flaeche farbe rand;
  Strich (weiss,rand);
  ] @ icons @ [
  flaeche durchsichtig [loesch];
  Strich (durchsichtig,[loesch]);
  ]


let kreisnorm r x y =
  let r2 = x*.x+.y*.y  in
  if r2>=r*.r
  then None
  else
    let z = sqrt (r*.r-.r2)  in
    Some (x/.r, y/.r, z/.r)

let normale_schema =
  let verbgrenz = coradius *. sqrt 0.5  in
  let verbnorm x y =
    let x = x-.0.5  in
    let x' = sqrt (coradius*.coradius -. y*.y)  in
    let r = 0.5-.x'  in
    if abs_float x>=r
    then  None
    else
      let z = sqrt (r*.r-.x*.x)  in
      let y = y*.r/.x'  in
      let betrag = sqrt (x*.x+.y*.y+.z*.z)  in
      Some (x/.betrag, -.y/.betrag, z/.betrag)  in
  fun (x,y) -> if x<=1.0 && y>=2.0 && y<=3.0
    then kreisnorm octirad
      (x -. if x<=0.5  then octi_p  else (1.0-.octi_p))
      (y -. if y<=2.5  then (2.0+.octi_p)  else (3.0-.octi_p))
    else if y>=4.0-.verbgrenz && y<=4.0+.verbgrenz
      then verbnorm (mod_float x 1.0) (y-.4.0)
      else if x>=1.0-.verbgrenz && x<=1.0+.verbgrenz && y>=3.0
        then match verbnorm (mod_float y 1.0) (x-.1.0)  with
          | None -> None
          | Some (nx,ny,nz) -> Some (ny,nx,nz)
        else kreisnorm radius
          (mod_float x 1.0 -. 0.5) (mod_float y 1.0 -. 0.5)

let normale_uhr (x,y) =
  kreisnorm uhr_rad (mod_float x 1.0 -. 0.5) (mod_float y 1.0 -. 0.5)

let glanz normale drunter =
  let lx,ly,lz = -.2.0, 1.0, 0.5  in
  let glanzmin = 0.5  in
  let glanzstaerke = 0.7  in
  let glanzmax = sqrt (lx*.lx+.ly*.ly+.lz*.lz)  in
  let b,h,farbe = drunter  in
  b,h,(fun p ->
    let alt = farbe p  in
    match normale p with
    | None -> alt
    | Some (nx,ny,nz) ->
      let sx,sy,sz = 2.0*.nz*.nx, 2.0*.nz*.ny, 2.0*.nz*.nz -. 1.0  in
      let glanz = sx*.lx+.sy*.ly+.sz*.lz  in
      if glanz<=glanzmin || alt=durchsichtig
      then alt
      else misch2 alt weiss
        (glanzstaerke*.(glanz-.glanzmin)/.(glanzmax-.glanzmin)))

let mach dinge normale b h =
  glanz normale (male
    (erzeuge_vektorbild dinge) (1.0/.32.0) (monochrom durchsichtig b h))

;;

let gric,command,outname = Gen_common.parse_args ()  in

let teil = coprefix command 3  in

let b,h,dinge,normale = if suffix teil 3 = "Uhr"
then
  let daten = List.assoc (cosuffix teil 3) strichdinge  in
  uhr_breite,uhr_hoehe,uhr daten,normale_uhr
else
  let farbe,icon = List.assoc teil dinge  in
  2,5, schema farbe icon, normale_schema  in

gib_xpm_aus (rgb_grau 0.0) outname (berechne gric (mach dinge normale b h))

