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

open Helfer
open Farbe
open Vektorgraphik
open Male_mit_aa

let strichdicke = 1.0/.32.0

let kopfradius = 0.5-.strichdicke/.2.0
let kopfcoradius = sqrt 0.5 -. kopfradius

let schema farbe =
  let rand = [konvertiere_polygon [
    Bogen ((0.5,1.5),kopfradius,true,pi*.0.25,pi*.1.25);
    Bogen ((0.0,1.0),kopfcoradius,false,pi*.2.25,pi*.1.75);
    Bogen ((0.5,0.5),kopfradius,true,pi*.0.75,pi*.1.75);
    Bogen ((1.0,0.0),kopfcoradius,false,pi*.0.75,pi*.0.25);
    Bogen ((1.5,0.5),kopfradius,true,pi*.1.25,pi*.2.25);
    Bogen ((2.0,1.0),kopfcoradius,false,pi*.1.25,pi*.0.75);
    Bogen ((1.5,1.5),kopfradius,true,pi*.1.75,pi*.2.75);
    Bogen ((1.0,2.0),kopfcoradius,false,pi*.1.75,pi*.1.25);
    Kreis ((1.0,1.0),kopfcoradius);
    ]]  in
  [
    flaeche farbe rand;
    Strich (schwarz,rand);
  ]

type mundspec =
| MBogen of (float * float)
  (* Die Parameter sind Krümmung (Positiv ist happy) und Breite. *)
| MSpline of (float * float * float)
  (* Die Parameter sind Mundwinkelwinkel (links), Höhe und Breite. *)
| MDSpline of (float * float * float * float)
  (* Die Parameter sind Mundwinkelwinkel (links), Höhe, Breite
     und relative Höhe in der Mitte (zwischen 0 und 1). *)
| MPanik1 | MPanik2 | MPanik3
| MOSpline of (float * float * float * float * float)
  (* Offener Mund mit Zähnen. Die ersten drei Parameter sind wie für MSpline
     und beziehen sich auf die Oberlippe. Die anderen sind Winkel und Höhe
     der Unterlippe. *)
| MODSpline of (float * float * float * float * float * float)
  (* Offener Mund. Die ersten vier Parameter sind wie für MDSpline und
     beziehen sich auf die Oberlippe. Die anderen sind Höhe und relative
     Höhe für die Unterlippe. *)


let spline winkel hoehe breite =
  let dx = hoehe /. tan winkel  in
  let dx,dy = if winkel>0.0  then dx,hoehe  else -.dx,-.hoehe  in
  [Spline ((-.breite/.2.0, -.dy/.2.0),
    (-.breite/.2.0+.dx*.4.0/.3.0, dy*.5.0/.6.0),
    (breite/.2.0-.dx*.4.0/.3.0, dy*.5.0/.6.0),
    (breite/.2.0, -.dy/.2.0))]

let dspline winkel hoehe breite relhoehe =
  let hoehe,relhoehe = if winkel>0.0
  then hoehe,relhoehe
  else -.hoehe,1.0-.relhoehe  in
  let koeff = List.hd
    (List.filter (fun k -> k>relhoehe) (Polynome.loese_3
      4.0  (-.3.0*.relhoehe-.9.0)
      (12.0*.relhoehe)  (-.4.0*.relhoehe*.relhoehe)))  in
  let dx = hoehe /. tan winkel  in
  let dx,dy = if winkel>0.0  then dx,hoehe  else -.dx,-.hoehe  in
  let max = 1.0  in
  let faktor = 1.0 +.
    List.hd (Polynome.loese_3 (4.0/.max) (-.9.0) 6.0 (-.1.0))  in
  [Spline ((-.breite/.2.0, -.hoehe/.2.0),
      (-.breite/.2.0+.hoehe*.koeff/.tan winkel, hoehe*.(koeff-.0.5)),
      (-.breite/.6.0, hoehe*.(relhoehe-.0.5)),
      (0.0, hoehe*.(relhoehe-.0.5)));
    Spline ((0.0, hoehe*.(relhoehe-.0.5)),
      (breite/.6.0, hoehe*.(relhoehe-.0.5)),
      (breite/.2.0-.hoehe*.koeff/.tan winkel, hoehe*.(koeff-.0.5)),
      (breite/.2.0, -.hoehe/.2.0));
    ]


let gesicht
    ?(drehung=0.0) ?(verschiebung=0.0) ?(mitkopf=false)
    blick ?(augezu=false) ?(lid=false) ?(profil=false)
    brauenrichtung brauenpos brauenwinkelaussen brauenwinkelinnen
    mundspec
    x y farbe =
  let augenradius = 0.1  in
  let augenabstand = 0.3  in
  let augenhoehe = 0.1  in
  let pupillenradius = 0.03  in
  let brauenlaenge = augenradius*.1.6  in
  let brauensep = 0.05  in
  let braueneffektaussen = brauenlaenge*.0.1  in
  let braueneffektinnen = brauenlaenge*.0.2  in
  let mundhoehe = -.0.2  in
  let lidwinkel = 200.0  in
  let panikmundwellenlaenge = 0.2  in
  let panikmundamplitude = 0.1  in
  let augezusteigung = 0.5  in

  let blickrichtung,blicksynchron = match blick with
  | None -> None,false
  | Some (r,s) -> Some r, s  in

  let xaugelinks = if profil
  then 0.3
  else -.augenabstand/.2.0  in
  let xaugerechts = augenabstand/.2.0  in
  let yauge = augenhoehe  in

  let augedoppel spiegel p = if profil
  then p
  else if spiegel
    then p @ (spiegel_polygon
      (verschiebe_polygon (-.xaugerechts-.xaugelinks) 0.0 p))
    else p @ (verschiebe_polygon (xaugerechts-.xaugelinks) 0.0 p)  in

  let augenrand,augenflaechen,lid = if lid
  then
    let oben = konvertiere_polygon [
      Bogen ((xaugelinks,yauge),augenradius,true,
        pi*.(0.5-.lidwinkel/.360.0), pi*.(0.5+.lidwinkel/.360.0));
      Bogen ((xaugerechts,yauge),augenradius,true,
        pi*.(0.5-.lidwinkel/.360.0), pi*.(0.5+.lidwinkel/.360.0));
      ]  in
    let unten = konvertiere_polygon [
      Bogen ((xaugelinks,yauge),augenradius,true,
        pi*.(0.5+.lidwinkel/.360.0), pi*.(2.5-.lidwinkel/.360.0));
      Bogen ((xaugerechts,yauge),augenradius,true,
        pi*.(0.5+.lidwinkel/.360.0), pi*.(2.5-.lidwinkel/.360.0));
      ]  in
    let dx = augenradius*.sin(lidwinkel*.pi/.360.0)  in
    let dy = augenradius*.cos(lidwinkel*.pi/.360.0)  in
    let mitte = konvertiere_polygon [
      Strecke ((xaugelinks-.dx,yauge+.dy),(xaugelinks+.dx,yauge+.dy));
      Strecke ((xaugerechts-.dx,yauge+.dy),(xaugerechts+.dx,yauge+.dy));
      ]  in
    [oben;unten;mitte],
    [flaeche weiss [unten; rueckwaerts mitte]],
    [flaeche farbe [oben; mitte]]
  else if augezu
  then
    [konvertiere_polygon (augedoppel false (
      [Strecke ((xaugelinks-.augenradius,yauge-.augenradius*.augezusteigung),
          (xaugelinks+.augenradius,yauge+.augenradius*.augezusteigung));
        Strecke ((xaugelinks-.augenradius,yauge+.augenradius*.augezusteigung),
          (xaugelinks+.augenradius,yauge-.augenradius*.augezusteigung))]))],
    [], []
  else
    let augen = [konvertiere_polygon (augedoppel (not blicksynchron)
      [Kreis ((xaugelinks,yauge),augenradius)])]  in
    augen, [flaeche weiss augen], []  in

  let blickweite,blickrichtunglinks = match blickrichtung  with
  | None -> 0.0,0.0
  | Some r -> augenradius*.0.5,r  in
  let pupillen = if augezu
  then []
  else [konvertiere_polygon (augedoppel (not blicksynchron)
    (verschiebe_polygon xaugelinks yauge
      (drehe_polygon blickrichtunglinks
      (verschiebe_polygon blickweite 0.0
      [Kreis ((0.0,0.0),pupillenradius)]))))]  in

  let braue x richtung pos winkellinks effektlinks winkelrechts effektrechts =
    let sl = effektlinks *. sin winkellinks  in
    let cl = effektlinks *. cos winkellinks  in
    let sr = effektrechts *. sin winkelrechts  in
    let cr = effektrechts *. cos winkelrechts  in
    (verschiebe_polygon x yauge
      (drehe_polygon richtung
      (verschiebe_polygon (augenradius+.brauensep) (brauenlaenge*.pos)
      [Spline ((-.sl,0.0), (0.0,-.cl),
        (0.0,-.brauenlaenge-.cr), (-.sr,-.brauenlaenge))])))  in
  let brauen = augedoppel true (
    braue xaugelinks brauenrichtung brauenpos
      brauenwinkelaussen braueneffektaussen
      brauenwinkelinnen braueneffektinnen)  in

  let mundprofil offenvorn offenhinten winkelvorn winkelhinten laenge
      effektvorn effekthinten =
    let neigung = (winkelvorn+.winkelhinten-.pi)/.2.0  in
    let sn,cn = sin neigung, cos neigung  in
    let xhinten,yhinten = 0.5-.laenge*.cn, mundhoehe-.laenge/.2.0*.sn  in
    let yvorne = mundhoehe+.laenge/.2.0*.sn  in
    let wv,wh = winkelvorn+.neigung, winkelhinten+.neigung  in
    let yvo,yvu = yvorne+.offenvorn/.2.0, yvorne-.offenvorn/.2.0  in
    let xvo = sqrt(kopfradius*.kopfradius-.yvo*.yvo)  in
    let xvu = sqrt(kopfradius*.kopfradius-.yvu*.yvu)  in
    let dxho,dyho = -.offenhinten/.2.0*.sin wh, offenhinten/.2.0*.cos wh  in
    let dxv,dyv = effektvorn*.cos wv, effektvorn*.sin wv  in
    let dxh,dyh = effekthinten*.cos wh, effekthinten*.sin wh  in
    let kwo = atan2 yvo xvo  in
    let kwu = atan2 yvu xvu  in
    [Spline ((xvo,yvo),(xvo+.dxv,yvo+.dyv),
      (xhinten+.dxho+.dxh,yhinten+.dyho+.dyh),(xhinten+.dxho,yhinten+.dyho));
      Bogen ((xhinten,yhinten),offenhinten/.2.0,true,
        winkelhinten+.neigung+.pi*.0.5,winkelhinten+.neigung+.pi*.1.5);
      Spline ((xhinten-.dxho,yhinten-.dyho),
        (xhinten-.dxho+.dxh,yhinten-.dyho+.dyh),(xvu+.dxv,yvu+.dyv),(xvu,yvu));
      Bogen ((0.0,0.0),kopfradius,false,kwu,kwo);
      ]  in

  let mund = match mundspec  with
  | MBogen (kruemmung,breite) -> if kruemmung=0.0
    then [Strecke ((-.breite/.2.0,mundhoehe),(breite/.2.0,mundhoehe))]
    else
      let radius = breite/.2.0 /. sin(kruemmung/.2.0)  in
      let hoehe = radius *. (1.0-.cos(kruemmung/.2.0))  in
      let y = mundhoehe+.radius-.hoehe/.2.0  in
      let radius,winkel1,winkel2 = if kruemmung>0.0
      then radius,(3.0*.pi-.kruemmung)/.2.0,(3.0*.pi+.kruemmung)/.2.0
      else -.radius,(pi+.kruemmung)/.2.0,(pi-.kruemmung)/.2.0  in
      [Bogen ((0.0,y),radius,true,winkel1,winkel2)]
  | MSpline (winkel,hoehe,breite) -> verschiebe_polygon 0.0 mundhoehe
    (spline winkel hoehe breite)
  | MDSpline (winkel,hoehe,breite,relhoehe) -> verschiebe_polygon 0.0 mundhoehe
    (dspline winkel hoehe breite relhoehe)
  | MPanik1 ->
    let ziel_x = sqrt(kopfradius*.kopfradius -. mundhoehe*.mundhoehe)  in
    let punkt n = (ziel_x-.panikmundwellenlaenge*.float_of_int n/.6.0,
      mundhoehe +. (match n mod 6 with
        | 0 | 3 -> 0.0
        | 1 | 2 -> panikmundamplitude
        | 4 | 5 -> -.panikmundamplitude) *. 2.0 /. float_of_int ((n+7)/3))  in
    [Spline (punkt 0, punkt 1, punkt 2, punkt 3);
      Spline (punkt 3, punkt 4, punkt 5, punkt 6);
      Spline (punkt 6, punkt 7, punkt 8, punkt 9);
      Spline (punkt 9, punkt 10, punkt 11, punkt 12);
      Spline (punkt 12, punkt 13, punkt 14, punkt 15);
      ]
  | MPanik2 -> mundprofil 0.15 0.1 2.7 0.7 0.6 0.2 0.2
  | MPanik3 -> mundprofil 0.1 0.05 pi 0.8 0.3 0.1 0.05
  | MOSpline (owinkel,ohoehe,breite,uwinkel,uhoehe) ->
    let opos,upos = if owinkel<0.0
    then (uhoehe-.ohoehe)/.2.0, 0.0
    else if uwinkel>0.0
      then 0.0, (uhoehe-.ohoehe)/.2.0
      else uhoehe/.2.0, -.ohoehe/.2.0  in
    (verschiebe_polygon 0.0 (mundhoehe+.opos)
      (spline owinkel ohoehe breite)) @
    (verschiebe_polygon 0.0 (mundhoehe+.upos)
      (spiegel_polygon (spline uwinkel uhoehe breite)))
  | MODSpline (winkel,ohoehe,breite,orelhoehe,uhoehe,urelhoehe) ->
    (verschiebe_polygon 0.0 (mundhoehe+.uhoehe/.2.0)
      (dspline winkel ohoehe breite orelhoehe)) @
    (verschiebe_polygon 0.0 (mundhoehe-.ohoehe/.2.0)
      (spiegel_polygon (dspline (winkel-.pi) uhoehe breite urelhoehe)))
  | _ -> []  in
  let mund = konvertiere_polygon mund  in

  let mund_flaeche = match mundspec with
  | MODSpline _ -> [flaeche (grau 0.3) [mund]]
  | _ -> []  in

  let zaehne = match mundspec with
  | MOSpline _ -> [
    flaeche weiss [konvertiere_polygon [
      Strecke ((-0.4,-0.4),(0.4,-0.4));
      Strecke ((0.4,-0.4),(0.4,0.4));
      Strecke ((0.4,0.4),(-0.4,0.4));
      Strecke ((-0.4,0.4),(-0.4,-0.4));
      ]];
    Strich (grau 0.3, [konvertiere_polygon [
      Strecke ((-0.4,mundhoehe),(0.4,mundhoehe));
      Strecke ((-0.2,-0.4),(-0.2,0.4));
      Strecke ((-0.1,-0.4),(-0.1,0.4));
      Strecke ((0.0,-0.4),(0.0,0.4));
      Strecke ((0.1,-0.4),(0.1,0.4));
      Strecke ((0.2,-0.4),(0.2,0.4));
      ]]);
    flaeche durchsichtig [mund; konvertiere_polygon [
      Strecke ((-0.45,-0.45),(0.45,-0.45));
      Strecke ((0.45,-0.45),(0.45,0.45));
      Strecke ((0.45,0.45),(-0.45,0.45));
      Strecke ((-0.45,0.45),(-0.45,-0.45));
      ]];
    ]
  | _ -> []  in

  let mund = if mitkopf
  then [mund; konvertiere_polygon [Kreis ((0.0,0.0),kopfradius)]]
  else [mund]  in

  let kopf = if match mundspec with
    | MPanik2 | MPanik3 -> true
    | _ -> mitkopf
  then [flaeche farbe mund]
  else []  in

  verschiebe_dinge (x+.0.5+.verschiebung) (y+.0.5) (drehe_dinge drehung (
    zaehne @ kopf @ augenflaechen @ [
    flaeche schwarz pupillen;
    Strich (schwarz,pupillen);
    ] @
    lid @ mund_flaeche @ [
    Strich (schwarz,
      konvertiere_polygon brauen :: mund @ augenrand);
    ]))


let nur_schema gesicht farbe =
  schema farbe @
  gesicht 0.0 0.0 farbe @
  gesicht 0.0 1.0 farbe @
  gesicht 1.0 0.0 farbe @
  gesicht 1.0 1.0 farbe


let fallend = gesicht
  (Some (280.0,false))
  120.0 0.2 (pi*.0.25) (pi*.0.75)
  (MSpline (pi*.0.6,0.11,0.15))

let leichtveraergert = gesicht
  None
  80.0 0.6 (pi*.0.25) (pi*.1.5)
  (MSpline (pi/.4.0,0.02,0.4))

let entspannt = gesicht
  (Some (270.0,true)) ~lid:true
  110.0 0.6 (pi*.0.15) (pi*.0.85)
  (MBogen (pi*.0.2,0.5))

let stoned = gesicht
  (Some (50.0,false))
  100.0 0.5 (pi*.0.15) (pi*.0.5)
  (MSpline (-.0.5*.pi, 0.15,0.7))

let panik mund = gesicht
  (Some (0.0,false)) ~profil:true
  150.0 0.3 (pi*.0.25) (pi*.0.75)
  mund

let veraergert = gesicht
  None
  60.0 1.1 (pi*.0.25) (pi*.1.5)
  (MDSpline (pi*.0.3,0.06,0.5,0.35))

let verdraengt = gesicht ~drehung:(-.10.0)
  (Some (190.0,true))
  80.0 0.5 (pi*.0.25) (pi*.0.75)
  (MDSpline (pi*.0.3,0.06,0.4,0.2))

let aufkommend = gesicht
  None ~augezu:true
  90.0 0.5 (-.pi*.0.25) (pi*.0.75)
  (MDSpline (pi*.0.5,0.02,0.5,-.0.5))

let verzweifelt = gesicht ~verschiebung:0.05
  None ~augezu:true
  105.0 0.5 (pi*.0.25) (pi*.0.75)
  (MDSpline (pi*.0.5,0.02,0.4,0.5))

let nachfallend = gesicht
  (Some (80.0,false))
  120.0 0.25 (pi*.0.15) (pi*.0.85)
  (MSpline (-.pi*.0.25,0.1,0.5))

let freundlich = gesicht
  None
  120.0 0.3 (pi*.0.25) (pi*.0.75)
  (MSpline (-.pi*.0.3,0.1,0.55))

let verraten = gesicht
  None
  115.0 0.2 (pi*.0.5) (pi*.0.5)
  (MDSpline (pi*.0.3,0.05,0.45,0.8))

let besorgt = gesicht
  (Some (70.0,false))
  90.0 0.55 (pi*.0.25) (pi*.1.75)
  (MDSpline (pi*.0.2,0.06,0.5,0.7))

let aergerlich = gesicht
  None
  75.0 0.75 (-.pi*.0.2) (pi*.1.3)
  (MSpline (pi*.0.3, 0.07, 0.45))

let besiegt = gesicht
  (Some (270.0,false)) ~lid:true
  110.0 0.3 (pi*.0.2) (pi*.1.3)
  (MDSpline (pi*.0.55, 0.04, 0.5, 0.3))

let aengstlich = gesicht
  None
  130.0 0.0 (pi*.0.1) (pi*.0.9)
  (MODSpline (pi*.0.5, 0.07, 0.45, 0.9, 0.08, 0.4))

let schmerzend = gesicht
  None
  100.0 0.3 (-.0.2*.pi) (1.2*.pi)
  (MODSpline (pi*.0.55, 0.1, 0.5, 0.5, 0.1, 0.6))

let laechelnd = gesicht
  None
  125.0 0.2 (pi*.0.25) (pi*.0.75)
  (MOSpline (-0.15*.pi, 0.05, 0.55, -0.4*.pi, 0.15))

let grinsend mitkopf = gesicht ~mitkopf:mitkopf
  None
  65.0 0.9 (-.pi*.0.2) (pi*.1.2)
  (MOSpline (-0.15*.pi, 0.04, 0.5, -0.4*.pi, 0.16))

let wuetend = gesicht
  None
  65.0 0.9 (-.pi*.0.2) (pi*.1.2)
  (MOSpline (0.4*.pi, 0.16, 0.45, 0.15*.pi, 0.04))

let gelangweilt = gesicht
  (Some (280.0,false)) ~lid:true
  100.0 0.4 (0.15*.pi) (0.85*.pi)
  (MDSpline (pi*.0.2, 0.03, 0.4, 0.7))



let gesichter farbe =
  fallend 0.0 0.0 farbe @
  entspannt 1.0 0.0 farbe @
  leichtveraergert 2.0 0.0 farbe @
  veraergert 3.0 0.0 farbe @
  panik MPanik1 0.0 1.0 farbe @
  spiegel_dinge (panik MPanik1 (-.2.0) 1.0 farbe) @
  verdraengt 2.0 1.0 farbe @
  spiegel_dinge (verdraengt (-.4.0) 1.0 farbe) @
  verzweifelt 0.0 2.0 farbe @
  spiegel_dinge (verzweifelt (-.2.0) 2.0 farbe) @
  nachfallend 2.0 2.0 farbe @
  aufkommend 3.0 2.0 farbe @
  freundlich 0.0 3.0 farbe @
  verraten 1.0 3.0 farbe @
  besorgt 0.0 4.0 farbe @
  aergerlich 1.0 4.0 farbe @
  besiegt 2.0 4.0 farbe @
  aengstlich 2.0 3.0 farbe @
  schmerzend 3.0 4.0 farbe @
  laechelnd 0.0 5.0 farbe @
  wuetend 1.0 5.0 farbe @
  grinsend false 2.0 5.0 farbe

let koepfe farbe =
  verschiebe_dinge 0.0 6.0 (schema farbe) @
  panik MPanik2 (1.0/.3.0) 0.0 farbe @
  spiegel_dinge (panik MPanik2 (-.5.0/.3.0) 1.0 farbe) @
  panik MPanik3 (2.0/.3.0) 2.0 farbe @
  spiegel_dinge (panik MPanik3 (-.4.0/.3.0) 3.0 farbe) @
  grinsend true (1.0/.3.0) 4.0 farbe @
  grinsend true (2.0/.3.0) 5.0 farbe

let gras = nur_schema gelangweilt (von_rgb (rgb_grau (1.0/.3.0)))

let grau = nur_schema stoned (von_rgb (rgb_grau (2.0/.3.0)))


let farben = [|
  1.0,0.9,0.2;
  1.0,0.2,0.1;
  0.5,0.3,1.0;
  1.0,0.4,0.8;
  0.0,0.8,0.1;
  0.2,0.7,1.0;
  0.6,0.3,0.2;
  |]

let hintergrundfarbe = rgb_grau 1.0

;;

let gric,command,outname = Gen_common.parse_args ()  in
let command = coprefix command 3  in

let w,h,c,p = match command with
| "Gras" -> 2,2,hintergrundfarbe,gras
| "Grau" -> 2,2,hintergrundfarbe,grau
| _ ->
  let number = int_of_string (suffix command 1)  in
  let command = cosuffix command 1  in
  let r,g,b = farben.(number-1)  in
  let farbe = rgbrgb r g b  in
  (match command with
  | "Gesichter" -> 4,6,farbe,gesichter (von_rgb farbe)
  | "Koepfe" -> 2,8,hintergrundfarbe,koepfe (von_rgb farbe))  in

Graphik.gib_xpm_aus c outname (Graphik.berechne gric (male
  (erzeuge_vektorbild p)
  strichdicke
  (Graphik.monochrom durchsichtig w h)))

