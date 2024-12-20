(*
   Copyright 2006,2007,2010,2011,2014 by Mark Weyer

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

let satt farbe = farbe, farbe
let blass farbe = farbe, misch2 farbe weiss 0.5

let farbraum = [
  satt (grau (1.0/.3.0));
  satt (grau (2.0/.3.0));
  blass (von_rgb (rgbrgb 0.95 0.0 0.0));
  blass (von_rgb (rgbrgb 0.0 0.9 0.1));
  blass (von_rgb (rgbrgb 0.2 0.3 1.0));
  blass (von_rgb (rgbrgb 1.0 1.0 0.0));
  blass (von_rgb (rgbrgb 0.9 0.0 1.0));
  ]

let leerpolygon = konvertiere_polygon []

let strichdicke = 0.025

let male breite hoehe bild =
  male bild (1.0/.32.0) (monochrom durchsichtig breite hoehe)

let raus gric methode name bild =
  gib_xpm_aus ~methode:methode (rgb_grau 1.0) name (berechne gric bild)

let rundzug (h::t) =
  let p,z = List.fold_left
    (function p,bisher -> function p' -> p',(Strecke (p,p'))::bisher)
    (h,[])  t  in
  (Strecke (p,h))::z



let kachel breite hoehe randsatt randblass (farbesatt,farbeblass) =
  let x0,y0,x1,y1 = -1.0, -1.0,
    float_of_int (breite+1), float_of_int (hoehe+1)  in
  let rahmen = konvertiere_polygon (rundzug [x0,y0; x1,y0; x1,y1; x0,y1])  in
  male breite hoehe (erzeuge_vektorbild [
    flaeche farbesatt [randsatt];
    flaeche farbeblass [randblass];
    Dicker_Strich (schwarz, strichdicke, [randsatt]);
    Dicker_Strich (schwarz, strichdicke, [randblass]);
    flaeche durchsichtig [randsatt; randblass; rahmen];
  ])

let kacheln breite hoehe randsatt randblass =
  let farben = List.length farbraum  in
  kombiniere_bildchen breite (farben*hoehe) (list_for 0 (farben-1)
    (fun i -> 0, i*hoehe,
      kachel breite hoehe randsatt randblass (List.nth farbraum i)))

let fall h rand farbe =
  male 1 h (erzeuge_vektorbild [
    Flaechen ([| fst (List.nth farbraum farbe) |], [rand,0, None]);
    Dicker_Strich (schwarz, strichdicke, [rand])
  ])

let faelle h rand =
  let anzahl = List.length farbraum  in
  kombiniere_bildchen anzahl h (list_for 1 anzahl (fun i -> i-1,0,
    fall h rand (anzahl-i)))



let punktaus punkte i x y = let x',y' = punkte.(i)  in x+.x', y+.y'



let sechseck =
  let kantenlaenge_x = 2.0/.(3.0+.(sqrt 3.0))  in
  let halbkante = kantenlaenge_x/.2.0  in
  let kantenlaenge_y = 1.0/.(1.0+.(sqrt 3.0))  in
  let dreieckshoehe = kantenlaenge_y*.(sqrt 0.75)  in
  [|
  kantenlaenge_x, 0.0;
  halbkante, dreieckshoehe;
  -.halbkante, dreieckshoehe;
  -.kantenlaenge_x, 0.0;
  -.halbkante, -.dreieckshoehe;
  halbkante, -.dreieckshoehe;
  |]

let punkt = punktaus sechseck

let sechseck_rahmen =
  let sechseck links unten rechts x y =
    (rundzug [punkt 0 x y; punkt 1 x y; punkt 2 x y;
      punkt 3 x y; punkt 4 x y; punkt 5 x y]) @
    (if links
      then [
        Strecke (punkt 3 x y, punkt 1 (x-.1.0) (y-.0.5));
        Strecke (punkt 4 x y, punkt 0 (x-.1.0) (y-.0.5))]
      else []) @
    (if unten
      then [
        Strecke (punkt 4 x y, punkt 2 x (y-.1.0));
        Strecke (punkt 5 x y, punkt 1 x (y-.1.0))]
      else []) @
    (if rechts
      then [
        Strecke (punkt 5 x y, punkt 3 (x+.1.0) (y-.0.5));
        Strecke (punkt 0 x y, punkt 2 (x+.1.0) (y-.0.5))]
      else [])  in
  erzeuge_vektorbild [Dicker_Strich (schwarz,strichdicke,[konvertiere_polygon (
    (sechseck true  false false 1.5 2.0) @
    (sechseck false true  true  0.5 1.5) @
    (sechseck true  true  false 1.5 1.0) @
    (sechseck false false true  0.5 0.5) @
    (sechseck false false false 1.5 0.0))])]

let sechseck_kacheln =
  let randsatt = konvertiere_polygon (
    (rundzug [
      punkt 0 0.5 0.5; punkt 1 0.5 0.5; punkt 2 0.5 0.5;
      punkt 3 0.5 0.5; punkt 4 0.5 0.5; punkt 5 0.5 0.5]))  in
  let randblass = konvertiere_polygon (
    (rundzug [
      punkt 1 1.5 0.0; punkt 5 1.5 1.0; punkt 4 1.5 1.0; punkt 2 1.5 0.0]) @
    (rundzug [
      punkt 3 3.5 0.5; punkt 2 3.5 0.5; punkt 0 2.5 1.0; punkt 5 2.5 1.0;
      punkt 3 3.5 0.5; punkt 1 2.5 0.0; punkt 0 2.5 0.0; punkt 4 3.5 0.5]) @
    (rundzug [
      punkt 3 4.5 0.5; punkt 5 3.5 1.0; punkt 1 3.5 0.0]) @
    (rundzug [
      punkt 0 4.5 0.5; punkt 2 5.5 0.0; punkt 4 5.5 1.0]))  in
  kacheln 6 1 randsatt randblass



let viereck =
  let halbkante = 1.0 /. (1.0+.(sqrt 3.0))  in
  [|
  halbkante, 0.0;
  1.0, halbkante;
  1.0-.halbkante, 1.0;
  0.0, 1.0-.halbkante;
  |]

let punkt = punktaus viereck

let ein_viereck x y umgekehrt = if umgekehrt
  then rundzug [punkt 0 x (y+.1.0); punkt 1 (x-.1.0) y;
    punkt 2 x (y-.1.0); punkt 3 (x+.1.0) y]
  else rundzug [punkt 0 x y; punkt 1 x y; punkt 2 x y; punkt 3 x y]

let zwei_vierecke x y = (ein_viereck x y false) @ (ein_viereck x (1.0-.y) true)

let viereck_rahmen =
  erzeuge_vektorbild [Dicker_Strich (schwarz,strichdicke,[konvertiere_polygon (
    (zwei_vierecke (-1.0) 0.0) @ (zwei_vierecke 0.0 (-1.0)) @
    (zwei_vierecke 1.0 0.0) @ (zwei_vierecke 2.0 1.0) @
    (zwei_vierecke 3.0 2.0) @ (zwei_vierecke 4.0 1.0) @
    [
      Strecke (punkt 2 (-1.0) 0.0, punkt 0 0.0 1.0);
      Strecke (punkt 3 1.0 0.0, punkt 1 0.0 1.0);
      Strecke (punkt 2 1.0 0.0, punkt 0 2.0 1.0);
      Strecke (punkt 3 3.0 0.0, punkt 1 2.0 1.0);
      Strecke (punkt 2 3.0 0.0, punkt 0 4.0 1.0);
    ])])]

let viereck_kacheln =
  let randsatt = konvertiere_polygon (
    (rundzug [
      punkt 0 2.0 0.0; punkt 1 2.0 0.0; punkt 2 2.0 0.0; punkt 3 3.0 1.0;
      punkt 0 2.0 2.0; punkt 1 1.0 1.0; punkt 2 2.0 0.0; punkt 3 2.0 0.0]))  in
  let randblass = konvertiere_polygon (
    (rundzug [punkt 0 1.0 1.0; punkt 1 0.0 0.0; punkt 2 0.0 0.0]) @
    (rundzug [punkt 0 1.0 1.0; punkt 3 1.0 1.0; punkt 2 0.0 0.0]) @
    (rundzug [punkt 1 3.0 1.0; punkt 2 4.0 0.0; punkt 3 4.0 0.0]) @
    (rundzug [punkt 1 3.0 1.0; punkt 0 3.0 1.0; punkt 3 4.0 0.0]))  in
  kacheln 5 2 randsatt randblass

let viereck_fall =
  let rand = konvertiere_polygon
    (rundzug [0.1,0.5; 0.5,0.1; 0.9,0.5; 0.5,0.9])  in
  faelle 1 rand



let abschnitt = ((sqrt 7.0)-.1.0)/.6.0

let fuenfeck x y r =
  let drehung = List.nth
    [(function x,y -> x,y); (function x,y -> 1.0-.y,x);
      (function x,y -> 1.0-.x,1.0-.y); (function x,y -> y,1.0-.x)]
    r  in
  let richtung x' y' = let x'',y'' = drehung (x',y')  in x+.x'',y+.y''  in
  rundzug [richtung abschnitt abschnitt;
    richtung 1.0 0.0; richtung (1.0+.abschnitt) (1.0-.abschnitt);
    richtung (1.0-.abschnitt) (1.0+.abschnitt); richtung 0.0 1.0]

let fuenfeck_rahmen =
  erzeuge_vektorbild [Dicker_Strich (schwarz,strichdicke,[konvertiere_polygon (
    (fuenfeck 0.0 1.0 0) @ (fuenfeck 1.0 2.0 2) @ (fuenfeck 0.0 2.0 1)
      @ (fuenfeck 0.0 (-1.0) 3) @ (fuenfeck 1.0 (-1.0) 0) @
    (fuenfeck 4.0 0.0 1) @ (fuenfeck 3.0 1.0 3) @ (fuenfeck 3.0 0.0 2)
      @ (fuenfeck 6.0 0.0 0) @ (fuenfeck 6.0 1.0 1) @
    (fuenfeck 5.0 4.0 2) @ (fuenfeck 4.0 3.0 0) @ (fuenfeck 5.0 3.0 3)
      @ (fuenfeck 5.0 6.0 1) @ (fuenfeck 4.0 6.0 2) @
    (fuenfeck 1.0 5.0 3) @ (fuenfeck 2.0 4.0 1) @ (fuenfeck 2.0 5.0 0)
      @ (fuenfeck (-1.0) 5.0 2) @ (fuenfeck (-1.0) 4.0 3)
    )])]

let fuenfeck_kacheln =
  let rand = konvertiere_polygon (
    (fuenfeck 0.0 0.0 0) @ (fuenfeck 2.0 1.0 2) @
    (fuenfeck 3.0 1.0 3) @ (fuenfeck 5.0 0.0 1))  in
  kacheln 6 2 rand leerpolygon

let fuenfeck_fall =
  let rad = 0.4  in
  let d = rad*.abschnitt  in
  let rand = konvertiere_polygon
    (rundzug [0.5-.2.0*.d, 0.5-.rad+.d;  0.5+.2.0*.d, 0.5-.rad+.d;
      0.5+.rad, 0.5+.d;  0.5, 0.5+.rad-.d;  0.5-.rad, 0.5+.d])  in
  faelle 1 rand


(* Ab jetzt arbeiten wir auf den 3D-Hetzrand hin. *)

(* a und b sind Parameter. a ist die halbe Länge der Fünfeckskante, zu der
   es keine symmetrische gibt. b ist die Amplitude der Knitterung. *)
let a = (sqrt(29.0)-.1.0)/.7.0        (* So werden die Winkel möglichst gut. *)
let b = sqrt ((3.0*.a+.2.0)*.a-.2.0)  (* So werden alle Kanten gleich lang. *)

let koord i j k =
  (* Gesucht ist ein Eckpunkt. i und j sind ganze Zahlen und adressieren
     ein 4x2-Feld, in dem sich 4 Fünfecke aufhalten. 0<=k<6 adressiert
     einen Punkt in diesem Feld. *)
  let x0,y0 = float_of_int (4*i+2*j), float_of_int (2*j)  in
  match k with
  | 0 -> (x0+.a, y0, -.b)
  | 1 -> (x0+.2.0, y0+.a, b)
  | 2 -> (x0+.4.0-.a, y0, -.b)
  | 3 -> (x0+.1.0, y0+.1.0, 0.0)
  | 4 -> (x0+.3.0, y0+.1.0, 0.0)
  | 5 -> (x0, y0+.2.0-.a, b)
  | _ -> raise (Invalid_argument "koord")

let si,co =
  let winkel = 0.2  in
  sin winkel, cos winkel
let trans1 (x,y,z) = (x*.co+.y*.si, y*.co-.x*.si, z)
let si,co =
  let winkel = 1.0  in
  sin winkel, cos winkel
let trans2 (x,y,z) = (x, y*.co-.z*.si, z*.co+.y*.si)
let trans3 (x,y,z) =
  let faktor = 0.4  in
  (x*.faktor+.5.0, y*.faktor+.0.3)
let trans p = trans3 (trans2 (trans1 p))

let punkt i j k = trans (koord i j k)

let fuenfeck kontrast i j k =
  (* Ähnlich zu koord. 0<=k<4 adressiert eines der 4 Fünfecke.
     Rückgabetyp ist (vektording list). *)
  let punkte = List.map (fun (i',j',k') -> trans(koord (i+i') (j+j') k'))
  (match k with
  | 0 -> [0,0,0; 0,0,3; 0,0,5; -1,0,4; -1,0,2]
  | 1 -> [0,0,0; 0,-1,4; 1,-1,5; 0,0,1; 0,0,3]
  | 2 -> [0,0,1; 0,0,4; 0,1,0; -1,1,2; 0,0,3]
  | 3 -> [0,0,3; -1,1,2; -1,1,4; -1,1,1; 0,0,5]
  | _ -> raise (Invalid_argument "fuenfeck"))  in
  let [p1;p2;p3;p4;p5] = punkte  in
  let poly = [konvertiere_polygon [
    Strecke (p1,p2);
    Strecke (p2,p3);
    Strecke (p3,p4);
    Strecke (p4,p5);
    Strecke (p5,p1)]]  in
  [flaeche (von_rgb (zufallsfarbe 1.0 kontrast)) poly;
    Strich (grau (1.0-.2.0*.kontrast), poly);]

let zeilen = 20
let extra_zeilen = 3

let zeile j =
  let kontrast =
    0.5*.(1.0-.float_of_int(min j zeilen)/.float_of_int(zeilen))  in
  List.concat (list_for (-6-j/2) (2-j/2)
      (fun i -> List.concat [
    fuenfeck kontrast i j 3;
    fuenfeck kontrast i j 2;
    fuenfeck kontrast i (j+1) 1]))

let fuenfeck_hetz = erzeuge_vektorbild (List.concat
  (list_for (zeilen+extra_zeilen) 1 zeile))



(* Alte Variante, bei der nicht immer alle Rahmen zu sehen sind. *)
let rhombus_rahmen =
  erzeuge_vektorbild [Dicker_Strich (schwarz,strichdicke,[konvertiere_polygon (
    (rundzug [1.0,-0.5; 4.0,1.0; 2.0,2.0; 4.0,3.0;
      1.0,4.5; -2.0,3.0; 0.0,2.0; -2.0,1.0]) @
    [Strecke ((1.0,0.5),(1.0,3.5));
      Strecke ((0.0,1.0),(1.0,1.5)); Strecke ((2.0,1.0),(1.0,1.5));
      Strecke ((0.0,3.0),(1.0,2.5)); Strecke ((2.0,3.0),(1.0,2.5))])])]

(* Wird auch nicht mehr gebraucht. *)
let rhombus_rahmen =
  erzeuge_vektorbild [Dicker_Strich (schwarz,strichdicke,[konvertiere_polygon (
    rundzug [0.0,0.0; 1.0,0.5; 1.0,2.5; 0.0,3.0; 0.0,2.0; 1.0,1.5; 0.0,1.0])])]

let rhombus_rand = konvertiere_polygon (
  (rundzug [0.0,2.5; 1.0,2.0; 2.0,2.5; 1.0,3.0]) @
  (rundzug [0.0,1.0; 1.0,0.5; 1.0,1.5; 0.0,2.0]) @
  (rundzug [2.0,0.5; 1.0,0.0; 1.0,1.0; 2.0,1.5]))

let rhombus_kacheln = kacheln 2 3 rhombus_rand leerpolygon

let rhombus_fall =
  let e = (1.0-.2.0*.strichdicke)/.4.0  in
  faelle 3 (konvertiere_polygon (
    rundzug [0.5,2.5-.e; 0.5+.2.0*.e,2.5; 0.5,2.5+.e; 0.5-.2.0*.e,2.5] @
    rundzug [0.5,1.5-.e; 0.5+.2.0*.e,1.5; 0.5+.2.0*.e,1.5+.2.0*.e; 0.5,1.5+.e] @
    rundzug [0.5,0.5-.e; 0.5+.2.0*.e,0.5-.2.0*.e; 0.5+.2.0*.e,0.5; 0.5,0.5+.e]))

let rhombus_leer = kachel 2 3 rhombus_rand leerpolygon (weiss,weiss)

;;

let gric,command,outname = Gen_common.parse_args ()  in

let bild = match command with

| "mkaSechseckRahmen" -> male 2 2 sechseck_rahmen
| "mkaSechseckKacheln" -> sechseck_kacheln

| "mkaViereckRahmen" -> male 4 2 viereck_rahmen
| "mkaViereckKacheln" -> viereck_kacheln
| "mkaViereckFall" -> viereck_fall

| "mkaFuenfeckRahmen" -> male 6 6 fuenfeck_rahmen
| "mkaFuenfeckKacheln" -> fuenfeck_kacheln
| "mkaFuenfeckFall" -> fuenfeck_fall
| "mkaFuenfeckHetz" -> male 10 10 fuenfeck_hetz

| "mkaRhombusKacheln" -> rhombus_kacheln
| "mkaRhombusFall" -> rhombus_fall
| "mkaRhombusLeer" -> rhombus_leer
  in

let methode = if command="mkaFuenfeckHetz"
  then Heuristik_mittlerer_euklidischer
  else Heuristik_maximaler_euklidischer  in

raus gric methode outname bild;

