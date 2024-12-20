(*
   Copyright 2006,2011 by Mark Weyer
   Maintenance modifications 2007,2010 by the cuyo developers

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

let gib_xpm_aus aufloesung name bild =
  gib_xpm_aus (rgb_grau 1.0) name (berechne aufloesung bild)

let farbraum_hai = [
  von_rgb (rgbrgb 0.25 0.5  0.95);
  von_rgb (rgbrgb 0.5  0.75 1.0);
  ]

let farbraum_krake = [
  von_rgb (rgbrgb 0.79 0.06 0.79);
  von_rgb (rgbrgb 0.95 0.37 0.96);
  ]

let farbraum3 =
  let o = von_rgb (rgbrgb 0.9 0.6 0.15)  in
  let w = von_rgb (rgbrgb 1.0 0.95 0.85)  in
  [
  von_rgb (rgbrgb 0.6 1.0 0.7);
  w;
  o;
  von_rgb (rgbrgb 0.85 0.2 0.05);
  o;
  w;
  ]

let farbraum4 = [
  von_rgb (rgbrgb 0.5  0.95 0.25);
  von_rgb (rgbrgb 0.75 1.0  0.5);
  ]

let farbraum_goldfisch = [
  von_rgb (rgbrgb 0.95 0.4 0.15);
  von_rgb (rgbrgb 1.0  0.7  0.4);
  ]

let farbraum6 =
  let w = von_rgb (rgbrgb 1.0 0.95 0.9)  in
  let s = von_rgb (rgbrgb 0.3 0.3 0.35)  in
  [s; w; s; w; s; w;]

let zug f (h::t) = snd (List.fold_left
  (function p,bisher -> function p' -> p',(f p p')::bisher)
  (h,[])  t)
let polygonzug = zug (function p -> function p' -> Strecke (p,p'))
let spline (x1,y1,dx1,dy1) (x2,y2,dx2,dy2) =
  Spline ((x1,y1),(x1+.dx1,y1+.dy1),(x2-.dx2,y2-.dy2),(x2,y2))
let splines = zug spline
let strich p = Strich (schwarz, p)
let umrande f ps = [flaeche f ps; strich ps]

let richtung (x,y) laenge winkel =
  let winkel = winkel*.pi/.180.0  in
  x, y, laenge*.(cos winkel), laenge*.(sin winkel)
let in_richtung p l w =
  let x,y,dx,dy = richtung p l w  in
  x+.dx, y+.dy
let punkt_auf_polygon p t =
  match punkt_auf_polygon_relativ p t  with
  p',Some w -> p',w



let korrektur bild = erzeuge_vektorbild (verschiebe_dinge 0.5 0.5 bild)

let male bild hintergrund = male (korrektur bild) (1.0/.32.0) hintergrund



type zustand =
  | Warten
  | Zucken
  | Fressen

let auge_rad = 0.07

let auge = konvertiere_polygon [Kreis ((0.0,0.0),auge_rad)]
let auge farbe zustand = if zustand=Zucken
  then umrande farbe [auge]
  else
    let pupille = konvertiere_polygon
      [Kreis ((0.5*.auge_rad,0.0),auge_rad*.0.5)]  in
    [
    Flaechen ([|schwarz;weiss|], [auge,1,None; pupille,0,Some 1]);
    strich [auge];
    ]
let auge (x,y) w farbe zustand =
  verschiebe_dinge x y (drehe_dinge w (auge farbe zustand))

let loeschdaten groesse =
  (if groesse > 0.6  then 0.4  else 0.3),
  (if groesse > 0.6  then -0.4  else -0.3),
  0.5 -. (groesse*.3.0 -. floor(groesse*.3.0))



let hai farbe groesse kiemenzahl zustand =

  let laenge = (groesse**(1.0/.3.0))*.0.4  in
  let dicke = (groesse**(2.0/.3.0))*.0.3  in
  let extralaenge = match zustand  with
  | Warten -> 0.0
  | Zucken -> -.laenge/.8.0
  | Fressen -> laenge/.8.0  in

  let mundwinkel = richtung (laenge/.2.0, -.dicke/.7.0) (laenge/.5.0) 240.0  in
  let mund,nase,kinn = if zustand=Fressen
    then (laenge*.3.0/.4.0, -.dicke/.7.0), (laenge, dicke), (laenge, -.dicke)
    else (laenge, 0.0), (laenge, dicke/.3.0), (laenge, -.dicke/.3.0)  in
  let mund1,mund2 = if zustand=Fressen
    then richtung mund (dicke/.2.0) 90.0, richtung mund (dicke/.2.0) 90.0
    else richtung mund (dicke/.7.0) 0.0, richtung mund (dicke/.7.0) 180.0  in
  let nasekinn_extrawinkel = if zustand=Fressen  then 60.0  else 0.0  in
  let nase1 = richtung nase (dicke/.7.0) (120.0+.nasekinn_extrawinkel)  in
  let nase2 = richtung nase (dicke/.2.0) (120.0+.nasekinn_extrawinkel)  in
  let nase3 = richtung nase (laenge/.2.0) (-30.0+.nasekinn_extrawinkel)  in
  let kinn1 = richtung kinn (dicke/.2.0) (60.0-.nasekinn_extrawinkel)  in
  let kinn2 = richtung kinn (dicke/.7.0) (60.0-.nasekinn_extrawinkel)  in
  let heck = -.laenge*.0.9-.extralaenge, 0.0  in
  let heck1 = richtung heck dicke 240.0  in
  let heck2 = richtung heck dicke 300.0  in
  let heck3 = richtung heck laenge (-15.0)  in
  let rumpf_oben = konvertiere_polygon [
    spline nase2 heck1;
    ]  in
  let rumpf_nur_unten = konvertiere_polygon [spline heck2 kinn1]  in
  let rumpf_unten = konvertiere_polygon [
    spline heck2 kinn1;
    spline kinn2 mund2;
    spline mund1 nase1;
    ]  in

  let auge_basis,auge_basis_w = punkt_auf_polygon rumpf_oben 0.3  in
  let auge_p = in_richtung auge_basis (auge_rad*.0.5) (auge_basis_w+.90.0)  in
  let oben_basis,oben_basis_w =
    punkt_auf_polygon rumpf_oben (if zustand=Zucken  then 0.63  else 0.6)  in
  let obenoben = in_richtung oben_basis (dicke*.0.6) (oben_basis_w-.90.0)  in
  let obenoben1 = richtung obenoben (dicke/.3.0) (oben_basis_w+.90.0)  in
  let obenoben2 = richtung obenoben (dicke/.3.0) (oben_basis_w-.15.0)  in
  let obenvorne =
    in_richtung oben_basis (laenge*.0.4) (oben_basis_w+.160.0)  in
  let obenvorne1 = richtung obenvorne (dicke/.3.0) (oben_basis_w-.90.0)  in
  let obenhinten =
    in_richtung oben_basis (laenge*.0.4) (oben_basis_w+.30.0)  in
  let obenhinten1 = richtung obenhinten (dicke/.3.0) (oben_basis_w+.45.0)  in
  let unten_basis,unten_basis_w = punkt_auf_polygon rumpf_nur_unten 0.55  in
  let untenunten = in_richtung unten_basis
    (if zustand=Zucken  then dicke/.5.0  else dicke/.3.0)
    (unten_basis_w-.90.0)  in
  let untenunten1 = richtung untenunten (laenge/.4.0) (unten_basis_w)  in
  let untenunten2 =
    richtung untenunten (laenge/.4.0) (unten_basis_w-.105.0)  in
  let untenvorne =
    in_richtung unten_basis (dicke*.0.6) (unten_basis_w+.30.0)  in
  let untenvorne1 =
    richtung untenvorne (dicke/.10.0) (unten_basis_w+.135.0)  in
  let untenhinten =
    in_richtung unten_basis (dicke/.3.0) (unten_basis_w+.50.0)  in
  let untenhinten1 =
    richtung untenhinten (dicke/.10.0) (unten_basis_w-.135.0)  in
  let schwanzoben = -.laenge*.1.1-.extralaenge, dicke  in
  let schwanzoben1 = richtung schwanzoben dicke (-75.0)  in
  let schwanzoben2 = richtung schwanzoben (laenge+.extralaenge) 165.0  in
  let schwanzunten = -.laenge*.1.1-.extralaenge, -.dicke  in
  let schwanzunten1 = richtung schwanzunten dicke (-105.0)  in
  let schwanzunten2 = richtung schwanzunten (laenge+.extralaenge) 15.0  in

  let rec kiemen n = if n=kiemenzahl
    then []
    else (Bogen
      ((dicke/.2.0-.(float_of_int n)*.(1.0/.12.0+.extralaenge/.4.0), 0.0),
        dicke/.2.0, true, pi*.5.0/.6.0, pi*.7.0/.6.0))
      :: (kiemen (n+1))  in
  let kiemen = [strich [konvertiere_polygon (kiemen 0)]]  in
  let kiemen = [strich [konvertiere_polygon (list_for 0 (kiemenzahl-1) (fun i ->
    Bogen ((dicke/.2.0-.(float_of_int i)*.(1.0/.12.0+.extralaenge/.4.0), 0.0),
      dicke/.2.0, true, pi*.5.0/.6.0, pi*.7.0/.6.0)))]]  in


  let schwanz = konvertiere_polygon [
    spline schwanzoben1 schwanzunten1;
    spline schwanzunten2 schwanzoben2;
    ]  in
  let oben = konvertiere_polygon
    (splines [obenoben1; obenhinten1; obenvorne1; obenoben2])  in
  let farbwechsel = konvertiere_polygon [spline heck3 nase3]  in
  let mund = konvertiere_polygon [spline mund2 mundwinkel]  in
  let unten = konvertiere_polygon
    (splines [untenunten1; untenvorne1; untenhinten1; untenunten2])  in
  let loescho,loeschu,loeschl = loeschdaten groesse  in
  let loeschen = konvertiere_polygon (polygonzug [
    0.0,0.0; nase; laenge,loescho; loeschl,loescho;
    loeschl,loeschu; laenge,loeschu; kinn; 0.0,0.0
    ])  in

  let schwanz = umrande (farbe 1) [schwanz]  in
  let oben = umrande (farbe 1) [oben]  in
  let rumpf = [
    Flaechen ([|farbe 1; farbe 2|],
      [rumpf_oben, 0, None; rumpf_unten, 1, None; farbwechsel, 0, Some 1]);
    strich ([rumpf_oben; rumpf_unten]
      @ (if zustand=Fressen  then []  else [mund]));
      (* beim Fressen ist der Mund Teil der unteren Mundlinie *)
    ]  in
  let auge = auge auge_p (auge_basis_w-.180.0) (farbe 1) zustand  in
  let unten = umrande (farbe 1) [unten]  in
  let loeschen = if zustand=Fressen
    then [flaeche hintergrund [loeschen]]
    else []  in

  loeschen @ schwanz @ oben @ rumpf @ kiemen @ auge @ unten



let krake farbe groesse augenzahl zustand =
  let laenge = (groesse ** 0.3)  in
  let dicke = groesse ** (1.0/.2.0)  in
  let tentakel_dicke = dicke*.0.02  in
  let tentakel_rand_dicke = tentakel_dicke+.1.0/.32.0  in
  let kopf_rad = dicke*.0.2  in
  let kopf_x = -.kopf_rad-.(if zustand=Fressen  then laenge*.0.2  else 0.0)  in
  let blesse_richtung = 130.0  in
  let blesse_breite = 50.0  in
  let augen = List.concat (List.map
    (function (r,w) ->
      auge (in_richtung (kopf_x,0.0) (r*.kopf_rad) w) 0.0 (farbe 1) zustand)
    (List.nth [
      [];
      [0.4,0.0];
      [0.6,45.0; 0.7,-110.0;];
      [0.65,-30.0; 0.7,50.0; 0.8,-130.0;]
    ] augenzahl))  in
  let tentakel ry rlaenge w1 w2 w3 w3' = if zustand=Fressen
    then konvertiere_polygon [Strecke
      ((kopf_x, kopf_rad*.ry), (kopf_x+.laenge*.rlaenge, dicke*.0.5*.ry))]
    else
      let laenge = laenge*.0.5*.rlaenge  in
      let p t =
	kopf_x/.2.0+.laenge*.t,
	(kopf_rad*.(1.0-.t)+.dicke*.0.3*.t)*.ry  in
      konvertiere_polygon (splines [
        richtung (p 0.0) (kopf_rad*.1.0) w1;
        richtung (p 0.3) (kopf_rad*.1.0) w2;
        richtung (p (if zustand=Zucken  then 0.85  else 1.0))
	  (kopf_rad*.1.0)
	  (if zustand=Zucken  then w3'  else w3)])   in
  let kopf = konvertiere_polygon
    [Kreis ((kopf_x,0.0),kopf_rad-.tentakel_dicke)]  in
  let blesse1,blesse2 =
    (kopf_x-.kopf_rad*.0.65,kopf_rad*.0.15),
    (kopf_x+.kopf_rad*.0.05,kopf_rad*.0.75)  in
  let blesse1,blesse2 =
    richtung blesse1 (kopf_rad/.3.0) 90.0,
    richtung blesse2 (kopf_rad/.3.0) 0.0  in
  let blesse = konvertiere_polygon (splines [blesse1;blesse2;blesse1])  in
  let kopf_vorne = [Flaechen ([|farbe 1; farbe 2|],
    [kopf, 0, None; blesse, 0, Some 1])]  in
  let dickstrich p = [
    Dicker_Strich (schwarz, tentakel_rand_dicke, p);
    Dicker_Strich (farbe 1, tentakel_dicke, p)]  in
  let rand_hinten = [
    tentakel (-0.5) 0.85 20.0 (-5.0) (-30.0) 0.0;
    tentakel 0.5 0.9 10.0 (-15.0) 15.0 (-15.0)]  in
  let rand_hinten = dickstrich rand_hinten  in
  let rand_vorne = [kopf;
    tentakel (-0.8) 1.0 60.0 0.0 45.0 15.0;
    tentakel 0.0 1.0 (-15.0) 30.0 0.0 30.0;
    tentakel 0.8 1.0 10.0 5.0 (-15.0) (-30.0);]  in
  let rand_vorne = dickstrich rand_vorne  in
  let loescho,loeschu,loeschl = loeschdaten groesse  in
  let loeschen = konvertiere_polygon (polygonzug [
    loeschl,loeschu;
    kopf_x+.laenge+.dicke*.0.1, loeschu;
    kopf_x+.laenge, dicke*. -0.4;
    kopf_x, kopf_rad*. -0.8;
    kopf_x, kopf_rad*.0.8;
    kopf_x+.laenge, dicke*.0.4;
    kopf_x+.laenge+.dicke*.0.1, loescho;
    loeschl, loescho;
    loeschl, loeschu])  in
  let loeschen = if zustand=Fressen
    then [flaeche hintergrund [loeschen]]
    else []  in
  loeschen @ rand_hinten @ rand_vorne @ kopf_vorne @ augen



let zierfisch farbe groesse kiemenzahl zustand =
  let laenge = groesse**(1.0/.2.0)*.0.8  in
  let mund_laenge = 0.1  in
  let zucklaenge = if zustand=Zucken  then laenge/.15.0  else 0.0  in
  let kiemenrad = laenge/.4.0  in
  let kiemend = laenge/.11.0  in

  let streifen_parameter = [
    0.2, 80.0, 105.0, 95.0;
    -0.3, 95.0, 80.0, 85.0;
    0.15, 70.0, 75.0, 65.0;
    0.1, 105.0, 95.0, 80.0;
    0.3, 75.0, 80.0, 95.0;
  ]  in
  let anz_streifen = List.length streifen_parameter + 1  in
  let streifen_x i =
    let i' = float_of_int(i)/.float_of_int(anz_streifen) -.0.5  in
    laenge *. i' -.
    if i'<0.0  then 2.0*.zucklaenge*.i'  else 0.0  in
  let streifen i =
    let h,wu,wm,wo = List.nth streifen_parameter (i-1)  in
    let x = streifen_x i  in
    let lm = laenge/.3.0  in
    konvertiere_polygon (splines [
      richtung (x,-.laenge/.2.0)  (lm*.(1.0+.h)) wu;
      richtung (x,laenge/.2.0*.h) lm             wm;
      richtung (x,laenge/.2.0)    (lm*.(1.0-.h)) wo;
    ])  in
  let streifen_rahmen i = konvertiere_polygon (
    Strecke ((streifen_x i,laenge/.2.0),(streifen_x (i-1),laenge/.2.0)) ::
    Strecke ((streifen_x (i-1),-.laenge/.2.0),(streifen_x i,-.laenge/.2.0)) ::
    if i=1
    then [Strecke ((streifen_x 0, laenge/.2.0),(streifen_x 0, -.laenge/.2.0))]
    else if i=anz_streifen
      then [Strecke ((laenge/.2.0, -.laenge/.2.0),(laenge/.2.0, laenge/.2.0))]
      else [])  in
  let streifen = Flaechen (
    Array.init anz_streifen (fun i -> farbe (i+1)),
    list_for 1 anz_streifen (fun i -> streifen_rahmen i, i-1, None) @
    list_for 1 (anz_streifen-1) (fun i -> streifen i, i-1, Some i))  in

  let mund = (laenge/.2.0, 0.0)  in
  let mund' = (laenge/.2.0-.mund_laenge, 0.0)  in
  let stirn = (laenge*.0.2, laenge/.4.0)  in
  let kinn = (laenge*.0.2, -.laenge/.4.0)  in
  let oben = (-0.15*.laenge, laenge/.2.0)  in
  let unten = (-0.15*.laenge, -.laenge/.2.0)  in
  let kreuz = (zucklaenge/.2.0-.laenge*.0.2, laenge/.8.0)  in
  let po = (zucklaenge/.2.0-.laenge*.0.2, -.laenge/.8.0)  in
  let obenh = (zucklaenge-.laenge/.2.0, laenge/.4.0)  in
  let untenh = (zucklaenge-.laenge/.2.0, -.laenge/.4.0)  in

  let mundo,mundu,mundw,stirnw = if zustand=Fressen
  then
    in_richtung mund (laenge/.2.0) 90.0,
    in_richtung mund (laenge/.2.0) 270.0,
    225.0,
    180.0
  else mund,mund,145.0,135.0  in
  let munduw,mundul = if zustand=Zucken
  then 80.0, laenge/.3.0
  else 540.0-.mundw, laenge/.6.0  in

  let umriss_aussen = List.concat [
    splines [
      richtung mundo (laenge/.6.0) mundw;
      richtung stirn (laenge/.6.0) stirnw;
      richtung oben (laenge/.6.0) 125.0;
    ];
    splines [
      richtung oben (laenge/.7.0) 260.0;
      richtung kreuz (laenge/.13.0) 225.0;
      richtung obenh (laenge/.9.0) 120.0;
    ];
    [Spline (obenh,
      in_richtung obenh (laenge/.6.0) 280.0,
      in_richtung untenh (laenge/.6.0) 80.0,
      untenh);
    ];
    splines [
      richtung untenh (laenge/.9.0) 60.0;
      richtung po (laenge/.13.0) 315.0;
      richtung unten (laenge/.7.0) 260.0;
    ];
    splines [
      richtung unten (laenge/.6.0) 55.0;
      richtung kinn (laenge/.6.0) (540.0-.stirnw);
      richtung mundu (laenge/.6.0) munduw;
    ]]  in

  let mund,umriss = if zustand=Fressen
  then [], Spline (mundu,mund',mund',mundo) :: umriss_aussen
  else [Strecke (mund,mund')], umriss_aussen  in
  let mund,umriss = konvertiere_polygon mund, konvertiere_polygon umriss  in

  let streifen_weg = flaeche durchsichtig [umriss;
    konvertiere_polygon (polygonzug [
      laenge/.2.0,  laenge/.2.0;
      -.laenge/.2.0,laenge/.2.0;
      -.laenge/.2.0,-.laenge/.2.0;
      laenge/.2.0,  -.laenge/.2.0;
      laenge/.2.0,  laenge/.2.0;
    ])]  in

  let loescho,loeschu,loeschl = loeschdaten groesse  in
  let loescho = max loescho (0.55*.laenge)  in
  let loeschu = min loeschu (-0.55*.laenge)  in
  let loeschl = min loeschl (-0.55*.laenge)  in
  let loeschen = if zustand=Fressen
  then [flaeche hintergrund [konvertiere_polygon (umriss_aussen @
    polygonzug [
      mundu;
      laenge*.0.55, loeschu;
      loeschl, loeschu;
      loeschl, loescho;
      laenge*.0.55, loescho;
      mundo;
    ])]]
  else []  in

  let kiemen = konvertiere_polygon (list_for 1 kiemenzahl (fun i ->
    Bogen ((kiemenrad-.kiemend*.float_of_int(i-2),0.0),
      kiemenrad,  true,  7.0*.pi/.8.0,  9.0*.pi/.8.0)))  in

  let zierrat = [mund; kiemen; umriss]  in
  let zierrat = [strich zierrat]  in

  let auge = auge
    (in_richtung stirn (laenge/.12.0) 270.0)
    0.0  (farbe 5)  zustand  in

  streifen :: streifen_weg :: loeschen @ zierrat @ auge



let seepferdchen farbe groesse flossenanzahl zustand =
  let hoehe = groesse ** (1.0/.2.0) *. 0.9  in
  let breite = hoehe/.2.0  in
  let schwanz_segmente = (if zustand=Zucken  then 7  else 5)*flossenanzahl  in
  let schwanz_y = -0.3*.hoehe  in
  let schwanz_x = 0.25*.breite  in
  let hueft_x1 = 0.0  in
  let hueft_x2 = -0.25*.breite  in
  let nacken_y = 0.3*.hoehe  in
  let flossenbreite = breite/.3.0  in
  let hals_w = 80.0  in
  let bauch_dicke = breite/.4.0  in
  let bauch_w = 20.0  in
  let mund_w = -20.0  in

  let schwanz_segmentef = float_of_int schwanz_segmente  in
  let schwanz_dw = pi/.3.0  in
  let schwanz_r1 = schwanz_x -. hueft_x1  in
  let schwanz_r2 = schwanz_x -. hueft_x2  in
  let schwanz_rf2 = (schwanz_r1/.schwanz_r2) ** (schwanz_dw/.2.0/.pi)  in
  let schwanz_rf1 =
    ((schwanz_r2/.schwanz_r1) ** (1.0/.schwanz_segmentef)) *. schwanz_rf2  in
  let schwanz_w1 = atan2 (log schwanz_rf1) schwanz_dw  in
  let schwanz_w2 = atan2 (log schwanz_rf2) schwanz_dw  in
  let schwanz r f w = konvertiere_polygon (splines
    (list_for 0 schwanz_segmente (fun i ->
      let if_ = float_of_int i  in
      let r = r*.(f**if_)  in
      let w' = pi+.schwanz_dw*.if_  in
      richtung (schwanz_x+.r*.cos w', schwanz_y+.r*.sin w')
        (r*.schwanz_dw/.3.0)
        ((w'+.pi/.2.0-.w)*.180.0/.pi))))  in
  let schwanz = [
    rueckwaerts (schwanz schwanz_r1 schwanz_rf1 schwanz_w1);
    schwanz schwanz_r2 schwanz_rf2 schwanz_w2;
    ]  in

  let koerper_h = nacken_y-.schwanz_y  in
  let ruecken_y = (nacken_y+.schwanz_y)/.2.0  in
  let ruecken_r = (schwanz_y-.ruecken_y) /. sin schwanz_w2  in
  let ruecken_x = hueft_x2 +. ruecken_r *. cos schwanz_w2  in
  let ruecken = konvertiere_polygon
    [Bogen ((ruecken_x,ruecken_y), ruecken_r, false,
      pi-.schwanz_w2, pi+.schwanz_w2)]  in
  let flossen = konvertiere_polygon (splines
    (list_for 0 (3*flossenanzahl) (fun i ->
      let w = schwanz_w2 *.
        (1.0 -. float_of_int i /. float_of_int flossenanzahl /. 1.5)  in
      let r = ruecken_r +.
        if i mod 3 = 1 || i mod 3 = 2  then flossenbreite  else 0.0  in
      richtung (ruecken_x-.r*.cos w,ruecken_y-.r*.sin w)
        (koerper_h/.(float_of_int flossenanzahl)/.2.0)
        (180.0/.pi*.(w -. pi/.2.0)))))  in

  let bauchsl = koerper_h/.6.0  in
  let nacken1 = hueft_x1,nacken_y  in
  let bauch = splines [
    richtung (hueft_x1,schwanz_y) bauchsl (180.0/.pi*.(pi/.2.0-.schwanz_w1));
    richtung (hueft_x1+.bauch_dicke, (2.0*.schwanz_y+.nacken_y)/.3.0)
      bauchsl  (90.0-.bauch_w);
    richtung (hueft_x1+.bauch_dicke, (schwanz_y+.2.0*.nacken_y)/.3.0)
      bauchsl  (90.0+.bauch_w);
    richtung nacken1 bauchsl hals_w;
  ]  in

  let kopf = (hueft_x1+.hueft_x2)/.2.0, nacken_y+.hoehe/.6.0  in
  let nacken2 = hueft_x2,nacken_y  in
  let mund = in_richtung
    ((hueft_x1+.hueft_x2)/.2.0,nacken_y+.hoehe/.9.0)
    (breite*.0.6)  mund_w  in
  let mundo = in_richtung mund 0.02 (mund_w+.90.0)  in
  let mundu = in_richtung mund 0.02 (mund_w-.90.0)  in
  let kopf = [
    Spline (nacken1,  in_richtung nacken1 (breite/.4.0) 340.0,
      in_richtung mundu (breite/.4.0) (mund_w+.183.0),  mundu);
    Strecke (mundu,mundo);
    Spline (mundo,  in_richtung mundo (breite/.3.0) (mund_w+.177.0),
      in_richtung kopf (breite/.3.0) 10.0,  kopf);
    Spline (kopf,
      in_richtung kopf (hoehe/.11.0) 260.0,
      in_richtung nacken2 (hoehe/.11.0) (90.0+.180.0/.pi*.schwanz_w2),
      nacken2);
  ]  in

  let restrand = konvertiere_polygon (bauch @ kopf) :: schwanz  in

  let auge = auge
    ((hueft_x1+.hueft_x1)/.2.0, nacken_y+.hoehe/.10.0)
    0.0  (farbe 1) zustand  in

  let loescho,loeschu,loeschl = loeschdaten groesse  in
  let fressor = (0.7,loescho)  in
  let fressur = (0.7,loeschu)  in
  let loeschen = if zustand=Fressen
  then [konvertiere_polygon (
    Spline (mund,  in_richtung mund 0.2 mund_w,
      in_richtung fressor 0.2 180.0,  fressor) ::
    Spline (fressur,  in_richtung fressur 0.2 180.0,
      in_richtung mund 0.2 mund_w,  mund) ::
    polygonzug [fressor; loeschl,loescho; loeschl,loeschu; fressur])]
  else []  in

  let linien = konvertiere_polygon (bauch @ kopf) :: ruecken :: flossen :: schwanz  in

  [
    flaeche hintergrund loeschen;
    Flaechen ([| farbe 1; farbe 2|],
      (flossen, 0, None) ::
      (ruecken, 0, Some 1) ::
      List.map (fun p -> p,1,None) restrand);
    strich linien;
  ] @ auge



let fuelle_parameter fisch verschieben groesse anzahl zustand farbe =
  let bild = fisch farbe (groesse/.3.0) anzahl zustand  in
  if verschieben
    then verschiebe_dinge (groesse-.(floor groesse)) 0.0 bild
    else bild

let fischkomplett fisch farbe =
  let statisch y n = [
    0,y,1,fisch (float_of_int n) n Warten;
    1,y,1,fisch (float_of_int n) n Zucken]  in
  let beweglich y n = [
    0,y,2,fisch ((float_of_int n)+.1.0/.3.0) n Fressen;
    0,y-1,2,fisch ((float_of_int n)+.2.0/.3.0) (n+1) Fressen]  in
  let haelfte = kombiniere_bildchen 2 7 (List.map
    (function x,y,w,b -> x,y, male (b farbe) (monochrom durchsichtig w 1))
    ((statisch 6 1) @ (beweglich 5 1)
      @ (statisch 3 2) @ (beweglich 2 2) @ (statisch 0 3)))  in
  kombiniere_bildchen 4 7 [0,0,haelfte; 2,0,spiegel_x haelfte]



let muschel augen oeffnung =
  let farbe = List.nth [
    schwarz;
    von_rgb (rgbrgb 0.9  1.0  0.5);
    von_rgb (rgbrgb 0.8  0.7  0.4);
    von_rgb (rgbrgb 0.3  0.3  0.3);
    ]  in
  let streifen = 5  in
  let costreifen = 3  in
  let rad = 0.4  in
  let dicke = 0.15  in
  let klappenwinkel = pi/.6.0  in
  let dreh (x,y,z) t = x, y*.(cos t)+.z*.(sin t)  in
  let punkt u t =
    let t' = 1.0-.t  in
    let u' = 2.0*.u-.1.0  in
    let w = u'*.pi*.0.5  in
    t*.rad*.(sin w) +. t'*.rad*.(sin klappenwinkel)*.u',
    t*.t'*.(1.0-.u'*.u')*.dicke*.4.0,
    -.t*.rad*.((cos klappenwinkel)+.(cos w))  in
  let punkt i j = punkt
    ((float_of_int i)/.(float_of_int streifen))
    ((float_of_int j)/.(float_of_int costreifen))  in
  let punkt w i j = dreh (punkt i j) w  in
  let punkt oben i j = if oben
    then punkt (0.1-.oeffnung) i j
    else let x,y = punkt (-0.1) i j  in x,-.y  in
  let minmax oben i =
    let rec versuche j (minj,miny) (maxj,maxy) = if j>costreifen
      then minj,maxj
      else
        let x,y = punkt oben i j  in
        versuche (j+1)
          (if y<=miny  then j,y  else minj,miny)
          (if y>=maxy  then j,y  else maxj,maxy)  in
    let x,y = punkt oben i 0  in
    versuche 1 (0,y) (0,y)  in
  let maxoben = Array.init (streifen+1) (function i -> snd (minmax true i))  in
  let minunten =
    Array.init (streifen+1) (function i -> fst (minmax false i))  in
  let liste f n =
    let rec erstelle i = if i>=n
      then []
      else (f i)::(erstelle (i+1))  in
    erstelle 0  in
  let zug f n = konvertiere_polygon
    (liste (function i -> Strecke (f i,f (i+1))) n)  in
  let haelfte oben extrema =
    let senkrecht1 = Array.init (streifen+1)
      (function i -> zug (function j -> punkt oben i j) extrema.(i))  in
    let senkrecht2 = Array.init (streifen+1)
      (function i -> zug (function j -> punkt oben i (j+extrema.(i)))
        (costreifen-extrema.(i)))  in
    let waagerecht1 = Array.init streifen
      (function i -> konvertiere_polygon
        [Strecke (punkt oben i 0, punkt oben (i+1) 0)])  in
    let waagerecht2 = Array.init streifen
      (function i -> konvertiere_polygon [Strecke
        (punkt oben i extrema.(i), punkt oben (i+1) extrema.(i+1))])  in
    let waagerecht3 = Array.init streifen
      (function i -> konvertiere_polygon
        [Strecke (punkt oben i costreifen, punkt oben (i+1) costreifen)])  in
    [Flaechen
      (Array.init streifen
        (function i -> misch2 (farbe 3) (farbe (1+(i mod 2))) oeffnung),
      (liste (function i -> waagerecht1.(i), i, None) streifen) @
      (liste (function i -> rueckwaerts (waagerecht2.(i)), i, None) streifen) @
      (liste (function i -> senkrecht1.(i+1), i, Some (i+1)) (streifen-1)) @
      [senkrecht1.(streifen), streifen-1, None;
        rueckwaerts senkrecht1.(0), 0, None]);
    Flaechen
      (Array.init streifen (function i -> farbe (1+(i mod 2))),
      (liste (function i -> waagerecht2.(i), i, None) streifen) @
      (liste (function i -> rueckwaerts (waagerecht3.(i)), i, None) streifen) @
      (liste (function i -> senkrecht2.(i+1), i, Some (i+1)) (streifen-1)) @
      [senkrecht2.(streifen), streifen-1, None;
        rueckwaerts senkrecht2.(0), 0, None]);
    strich
      ((Array.to_list waagerecht1) @
      (Array.to_list waagerecht2) @
      (Array.to_list waagerecht3) @
      [senkrecht1.(0);senkrecht2.(0);
        senkrecht1.(streifen);senkrecht2.(streifen)])
    ]  in
  let augen = match augen  with
  | None -> []
  | Some rechts ->
    (auge (0.13,0.0) (if rechts  then 0.0  else 180.0) weiss Warten) @
    (auge (-0.13,0.0) (if rechts  then 0.0  else 180.0) weiss Warten)  in
  verschiebe_dinge 0.0 (-0.2)
    ((haelfte false minunten)@(haelfte true maxoben)@augen)


let muschelkomplett u =
  let schliessbilder = 5  in
  let minoeffnung = 0.1  in
  let rec schliessen i = if i>=schliessbilder
    then []
    else (i,None,minoeffnung +. (1.0-.minoeffnung)*.
        (float_of_int i)/.(float_of_int (schliessbilder-1)))
      ::(schliessen (i+1))  in
  let bilder =
    (schliessbilder,Some true,minoeffnung) ::
    (schliessbilder+1,Some false,minoeffnung) ::
    (schliessen 0)  in
  let hintergrund = monochrom durchsichtig 1 1  in
  kombiniere_bildchen (schliessbilder+2) 1
    (List.map
      (function i,a,o -> i,0,
        male (muschel a o) hintergrund)
      bilder)



type qzustand = Auf | Zu | Mitte

let qualle zustand unten =
  let farbe = List.nth [
    schwarz;
    von_rgb (rgbrgb 1.0  0.3  0.3);
    von_rgb (rgbrgb 0.9  0.8  0.5);
    von_rgb (rgbrgb 0.8  0.9  1.0);
    ]  in
  let faden_dicke = 0.02  in
  let faden_spline_staerke = 0.2  in
  let glocke_spline_staerke = 0.6  in
  let faden_rand_dicke = faden_dicke +. 1.0/.32.0  in
  let faden staerke p1 p2 w =
    let p3 = in_richtung p2 0.07 w  in
    let sp1,sp2,sp3 =
      richtung p1 staerke 270.0,
      richtung p2 staerke w,
      richtung p3 staerke w  in
    let anfang,ende =
      konvertiere_polygon [spline sp1 sp2],
      konvertiere_polygon [spline sp2 sp3]  in
    [Dicker_Strich (schwarz, faden_rand_dicke, [anfang;ende]);
    Dicker_Strich (farbe 2, faden_dicke, [anfang]);
    Dicker_Strich (farbe 1, faden_dicke, [ende])]  in
  let faeden x y1 y2 w =
    let faden t = faden
      (faden_spline_staerke *. (y1-.y2))
      (0.175*.t,y1)
      (x*.t,y2+.0.05*.t*.t)
      (270.0+.w*.t)  in
    (faden (-1.0))@(faden (-1.0/.3.0))@(faden (1.0/.3.0))@(faden 1.0)  in
  let glocke x y1 y2 w =
    let staerke = glocke_spline_staerke *. (y1-.y2)  in
    let p1,p2,p3 = (-.x,y2), (x,y2), (0.0,y1)  in
    let sp1,sp1',sp2,sp2',sp3 =
      richtung p1 staerke (-.w),
      richtung p1 staerke (270.0-.w),
      richtung p2 staerke w,
      richtung p2 staerke (90.0+.w),
      richtung p3 staerke 180.0  in
    konvertiere_polygon [
      spline sp1 sp2;
      spline sp2' sp3;
      spline sp3 sp1']  in
  let glocke,faeden = match zustand  with
  | Auf -> glocke 0.45 0.3 0.0 45.0,
      faeden 0.35 0.1 (-0.2) 45.0
  | Zu -> glocke 0.30 0.4 (-0.15) (-15.0),
      faeden 0.25 0.15 (-0.35) 15.0
  | Mitte -> glocke 0.35 0.3 (-0.1) 15.0,
      faeden 0.3 0.1 (-0.25) 30.0  in
  if unten
  then (umrande (farbe 3) [glocke]) @ faeden
  else umrande (misch2 durchsichtig (farbe 3) 0.5) [glocke]

let qualle_komplett u =
  let hintergrund = monochrom durchsichtig 1 1  in
  kombiniere_bildchen 3 1
    (List.map
      (fun (x,z) ->
        let q u = male (qualle z u) hintergrund  in
        x,0,ueberlagerung (q true) (q false) None)
      [0,Mitte; 1,Auf; 2,Zu])




let fischraus gric name farbraum fisch =
  gib_xpm_aus gric name
    (fischkomplett (fuelle_parameter fisch true)
      (fun i -> List.nth farbraum (i-1)))

let muschelraus gric name = gib_xpm_aus gric name (muschelkomplett ())

let qualleraus gric name = gib_xpm_aus gric name (qualle_komplett ())

;;


let gric,command,outname = Gen_common.parse_args ()  in

match command with
| "mfmuschel" -> muschelraus gric outname
| "mfqualle" -> qualleraus gric outname
| _ -> let farbraum,form = match command with
  | "mffisch1" -> farbraum_hai, hai
  | "mffisch2" -> farbraum_krake, krake
  | "mffisch3" -> farbraum6, zierfisch
  | "mffisch4" -> farbraum4, seepferdchen
  | "mffisch5" -> farbraum3, zierfisch
  | "mffisch6" -> farbraum_goldfisch, hai  in
  fischraus gric outname farbraum form

