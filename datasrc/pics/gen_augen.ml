(*
   Copyright 2010,2011 by Mark Weyer
   Maintenance modifications 2014 by the cuyo developers

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
open Male_mit_aa
open Helfer

module RGB = Vektor.Vektor(Natmod.Drei)

let aa = 5

let haut_rgb = rgbrgb 1.0 0.8 0.6
let schatten_rgb = rgbrgb 0.7 0.4 0.1
let blitzhell = 0.7
let aug_rad = 0.8
let augenlaenge = 1.8
let lidabstand = 0.1
let augenhoehe = 0.65
let anz_wimpern = 25
let wimplaeng = 0.2
let iris_rad = 0.3
let pup_rad_klein = 0.07
let pup_rad_gross = 0.13
let sicht_abstand = 8.0
let schattenversatz = 0.3

let farben1 = [|
  0.0, 0.6, 0.0;
  0.1, 0.3, 0.8;
  0.5, 0.1, 0.0;
  0.2, 0.6, 1.0;
  1.0, 0.5, 0.0;
  |]

let farben2 = [|
  0.9, 0.7, 0.0;
  0.2, 0.6, 1.0;
  0.6, 0.2, 0.1;
  1.0, 0.7, 0.3;
  0.1, 0.6, 0.1;
  |]

let streifenanzahlen = [| 17; 15; 13; 16; 14|]


let misch_bilder mischer rot gruen blau schwarz =
  let b,h,mischer = mischer  in
  let _,_,rot = rot  in
  let _,_,gruen = gruen  in
  let _,_,blau = blau  in
  b,h,(fun p ->
    let m = mischer p  in
    let r = nur_rot m  in
    let g = nur_gruen m  in
    let b = nur_blau m  in
    let s = 1.0-.r-.g-.b  in
    misch [r,rot p; g,gruen p; b,blau p; s,schwarz])

let blau_absolut (b,h,f) = b,h,fun p ->
  let f = f p  in
  if nur_blau f > 0.0  then blau  else f


let polar x y =
  let r = sqrt (x*.x +. y*.y)  in
  let w = if r=0.0  then 0.0  else atan2 y x  in
  r,w

let dreh w x y =
  let cw,sw = cos w, sin w  in
  cw*.x -. sw*.y, cw*.y +. sw*.x

let farbe_aus_array nummer array =
  let r,g,b = array.(nummer)  in
  von_rgb (rgbrgb r g b)


let haut = von_rgb haut_rgb
let blitzhaut_rgb = RGB.plus
  (RGB.mal (1.0-.blitzhell) haut_rgb)
  (rgb_grau blitzhell)
let blitzhaut = von_rgb blitzhaut_rgb
let schatten = von_rgb schatten_rgb
let blitzschatten_rgb = RGB.plus
  (RGB.mal (1.0-.blitzhell) schatten_rgb)
  (rgb_grau blitzhell)
let blitzschatten = von_rgb blitzschatten_rgb
let blitzschwarz = grau blitzhell

let lidwinkel = asin (augenhoehe/.2.0/.aug_rad)
let lidmin = (1.0-.augenhoehe) /. 2.0
let nl = 1.5-.augenlaenge/.2.0
let nr = 1.5+.augenlaenge/.2.0
let pul = nl, 0.5+.lidabstand/.2.0
let pur = nr, 0.5+.lidabstand/.2.0
let pol = nl, 0.5-.lidabstand/.2.0
let por = nr, 0.5-.lidabstand/.2.0
let fl = 0.5-.(2.0-.augenlaenge)/.4.0
let fr = 2.5+.(2.0-.augenlaenge)/.4.0

let lid dx offen =
  let woffen = lidwinkel *. (2.0*.offen-.1.0)  in
  let offen = 0.5 +. aug_rad *. sin woffen  in
  let maxoffen = 0.5 +. aug_rad *. sin lidwinkel  in
  let unterlid = konvertiere_polygon
    [Spline (pul,(1.0,lidmin),(2.0,lidmin),pur)]  in
  let unterrahmen = konvertiere_polygon [
    Strecke (pur,(nr,1.0));
    Strecke ((nr,1.0),(nl,1.0));
    Strecke ((nl,1.0),pul);
    ]  in
  let oberlid = konvertiere_polygon
    [Spline (pol,(1.0,offen),(2.0,offen),por)]  in
  let oberrand = konvertiere_polygon
    [Spline (por,(2.0,maxoffen),(1.0,maxoffen),pol)]  in
  let wimper = [Strecke ((0.0,0.0),(0.0,wimplaeng *. sin woffen))]  in
  let wimpern = konvertiere_polygon (List.concat (list_for 1 anz_wimpern
    (fun i ->
      let (x,y),Some winkel = punkt_auf_polygon_relativ oberlid
        ((float_of_int i-.0.5)/.(float_of_int anz_wimpern))  in
      verschiebe_polygon x y (drehe_polygon winkel wimper))))  in
  let oberrahmen = konvertiere_polygon [
    Strecke (pol,(fl,0.5));
    Strecke ((fl,0.5),(fl,1.5));
    Strecke ((fl,1.5),(fr,1.5));
    Strecke ((fr,1.5),(fr,0.5));
    Strecke ((fr,0.5),por);
    ]  in
  let grund = konvertiere_polygon [
    Strecke ((0.0,0.0),(1.0,0.0));
    Strecke ((1.0,0.0),(1.0,1.0));
    Strecke ((1.0,1.0),(0.0,1.0));
    Strecke ((0.0,1.0),(0.0,0.0));
    ]  in
  let einmal = verschiebe_dinge dx 0.0 [
    flaeche blau [unterlid; unterrahmen];
    Strich (schwarz,[unterlid]);
    flaeche gruen [oberlid; oberrand];
    flaeche rot [oberrand; oberrahmen];
    Strich (gruen,[oberrand]);
    Strich (schwarz,[oberlid; wimpern]);
    ]  in
  male
    (erzeuge_vektorbild (
      flaeche rot [grund] ::
      einmal @
      (verschiebe_dinge 2.0 0.0 einmal)))
    (1.0/.32.0)  (monochrom durchsichtig 1 1)


let lidhoehe = lidabstand /. 8.0 +. aug_rad*.sin lidwinkel *. 0.75
let schattenrad = sqrt (schattenversatz*.schattenversatz +. lidhoehe*.lidhoehe)

let schattenhaut dx haut schatten = male
  (erzeuge_vektorbild [Dicker_Strich (schatten,schattenrad*.0.75,
    [konvertiere_polygon [
      Strecke ((0.5+.schattenversatz+.dx,0.0),(1.5-.schattenversatz+.dx,0.5));
      Strecke ((0.5+.schattenversatz+.dx,1.0),(1.5-.schattenversatz+.dx,0.5));
      Strecke ((1.5+.schattenversatz+.dx,0.5),(2.5-.schattenversatz+.dx,0.0));
      Strecke ((1.5+.schattenversatz+.dx,0.5),(2.5-.schattenversatz+.dx,1.0));
      ]])])
  (schattenrad*.0.5)
  (monochrom haut 1 1)


let anz = 4
let div = float_of_int(anz-1)

let lider ?spezial dx schwarz haut lidf schatten weiss = kombiniere_bildchen
  anz
  (if dx = -2.0  then 1  else 2)
  (List.concat
    (list_for 0 1 (fun j -> list_for 0 (anz-1) (fun i -> i,j,
      let lid = lid dx (float_of_int i /. div)  in
      let haut' = if j=0 && dx = -1.0
      then schattenhaut dx haut schatten
      else monochrom haut 1 1  in
      if spezial=Some () && i=anz-1 && j=1
      then monochrom durchsichtig 1 1
      else
        let lid = if spezial=Some () && i=anz-1
        then blau_absolut lid
        else lid  in
          misch_bilder lid
            haut'
            (monochrom lidf 1 1)
            (monochrom weiss 1 1)
            schwarz))))


let kern_auge nummer mit_weiss pup_rad x y =
  let farbe1 = farbe_aus_array nummer farben1  in
  let farbe2 = farbe_aus_array nummer farben2  in
  let streifen = streifenanzahlen.(nummer)  in
  let r,winkel = polar x y  in
  if r <= iris_rad
  then if r <= pup_rad
    then schwarz
    else
      let r = (r-.pup_rad)/.(iris_rad-.pup_rad)  in
      if r <= 1.0 -. abs_float (sin (winkel *.float_of_int streifen/.2.0))
      then farbe2
      else farbe1
  else if mit_weiss  then weiss  else durchsichtig

let auge gric nummer mit_weiss pup_rad richtung =
  let richtung,abstand = match richtung with
  | None -> 0.0,0.0
  | Some r -> r,2.0  in
  let drehung = atan2 abstand sicht_abstand  in
  let drunter = abstrahiere gric (durchschnitt aa (berechne (gric*aa)
    (1,1, (fun (x,y) ->
      let x,y = x-.0.5, y-.0.5  in
      let z = sqrt (aug_rad*.aug_rad -. x*.x -. y*.y)  in
      let x,y = dreh (-.richtung) x y  in
      let x,z = dreh drehung x z  in
      let x,y = dreh richtung x y  in
      kern_auge nummer mit_weiss pup_rad x y))))  in
  if mit_weiss
  then misch_bilder
    (lid (-.1.0) 1.0)
    (monochrom haut 1 1)
    (monochrom haut 1 1)
    drunter
    schwarz
  else drunter

let phasen = 4
let phasenf = float_of_int phasen
let zeilen = 2
let schauphasen = (phasenf+.2.0)*.float_of_int zeilen

let augen gric nummer = kombiniere_bildchen (phasen+2) (4*zeilen+1)
  (List.concat (list_for 0 (4*zeilen)
    (fun j -> list_for 0 (phasen+1) (fun i -> i,j,
      if j=4*zeilen
      then if i>phasen
        then auge gric nummer false pup_rad_gross None
        else auge gric nummer true
          (pup_rad_klein +.
            (pup_rad_gross-.pup_rad_klein)*.(float_of_int i) /. phasenf)
          None
      else
        let i,j = i+(zeilen-1-j mod zeilen)*(phasen+2), j/zeilen  in
        let winkel = pi *. float_of_int j /. 2.0 -. atan2
          (2.0 *. float_of_int i -. schauphasen)
          schauphasen  in
        auge gric nummer true pup_rad_gross (Some winkel)))))

;;

let gric,command,outname = Gen_common.parse_args ()  in

let teil = coprefix command 2  in

match teil with
| "Auge" -> (* Das hier ist fuer "mdAuge", alles andere fuer "ma..." *)
  (* Hier hat outname womoeglich den falschen Wert, naemlich "mdAuge.xpm"
     statt "mdAuge.ppm". Der ist aber nur falsch, wenn er nicht durch -o
     angegeben wurde. Also nochmal nachschauen. *)
  let outname = (
    let gibt_o = ref false  in
    for i=1 to Array.length Sys.argv - 1 do
      if Sys.argv.(i)="-o" then gibt_o := true
    done;
    if !gibt_o then outname  else command^".ppm"
  )  in
  gib_ppm_aus outname (berechne gric (2,2,
    (fun (x,y) -> kern_auge 4 true pup_rad_gross (x-.1.0) (y-.1.0))))
| "LidA" -> gib_xpm_aus (rgb_grau 1.0) outname (berechne gric
  (lider ~spezial:() (-.1.0) schwarz haut haut schatten durchsichtig))
| "LidB" -> gib_xpm_aus (rgb_grau 1.0) outname (berechne gric
  (lider (-.1.0) blitzschwarz blitzhaut blitzhaut blitzschatten durchsichtig))
| "LidC" -> gib_xpm_aus haut_rgb outname (berechne gric
  (lider (-.2.0) schwarz durchsichtig haut durchsichtig weiss))
| "LidD" -> gib_xpm_aus blitzhaut_rgb outname (berechne gric
  (lider (-.2.0) blitzschwarz durchsichtig blitzhaut durchsichtig weiss))
| _ ->
  let nummer = int_of_string teil - 1  in
  gib_xpm_aus haut_rgb outname (berechne gric (augen gric nummer))

