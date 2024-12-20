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

open Farbe
open Graphik
open Helfer

module Rgb = Vektor.Vektor(Natmod.Drei)

let leer_stuetzen = 100

let leer gric =
  let stuetzpunkte = List.concat (List.map
    (fun (x,y,f) -> [x,y-.20.0,f; x,y,f; x,y+.20.0,f])
    (Array.to_list (Array.init leer_stuetzen (fun i ->
      (Random.float 20.0 -. 5.0,
      Random.float 20.0,
      von_rgb (zufallsfarbe 0.3 0.2))))))  in
  berechne gric (10,20, fun (x,y) -> misch
    (List.map
      (fun (x',y',f) -> (0.75 ** ((x'-.x)*.(x'-.x) +. (y'-.y)*.(y'-.y)), f))
      stuetzpunkte))

let hinter gric =
  let breite = gric*10  in
  let hoehe = gric*20  in
  let stuetzen = gric*gric*5  in
  let stuetzpunkte = Array.init stuetzen (fun i ->
    let f1 = zufallsfarbe 1.0 0.5  in
    let f2 = Rgb.mal 0.5 f1  in
    (Random.int (breite+gric) - gric,
    Random.int hoehe,
    von_rgb f1,
    von_rgb f2))  in
  Array.sort
    (fun (x1,y1,_,_) -> fun (x2,y2,_,_) -> x1-x2 + 2*(y1-y2))
    stuetzpunkte;
  (breite,hoehe, Array.init hoehe (fun y -> Array.init breite (fun x ->
    Array.fold_left
      (fun f -> fun (x',y',f1,f2) ->
        if x>=x' && y>=y'
        then if x=x' || y=y'
          then f1
          else f2
        else f)
      schwarz
      stuetzpunkte)))

let verbind_stuetzen = 100
let verbind_bilder = 10

let normalisier rand corand wert =
    (* Führt eine lineare Transformation durch,
       die rand aud -1 und corand auf 1 wirft. *)
  let c1 = (rand+.corand) /. 2.0  in
  let c2 = (corand-.rand) /. 2.0  in
  (wert -. c1) /. c2

let misch3 rand corand links rechts wert =
    (* Als Funktion im letzten Argument ist misch3 konstant gleich links
       bis rand und konstant gleich rechts ab corand. Dazwischen
       interpoliert ein kubisches Polynom. *)
  let wert = normalisier rand corand wert  in
  if wert <= -1.0
  then links
  else if wert >= 1.0
    then rechts
    else
      let a = (links-.rechts) /. 4.0  in
      let d = (links+.rechts) /. 2.0  in
      (wert*.wert-.3.0)*.a*.wert+.d

let misch4 rand corand default sonst wert =
    (* Als Funktion im letzten Argument ist misch4 konstant gleich default
       bis rand und ab corand. Dazwischen interpoliert ein Polynom vom Grad 4
       mit Wert sonst in der Mitte. *)
  let wert = normalisier rand corand wert  in
  if wert <= -1.0 || wert >= 1.0
  then default
  else
    (wert*.wert-.2.0)*.(sonst-.default)*.wert*.wert+.sonst

let huegel rand corand wert =
  let wert = normalisier rand corand wert  in
  if wert <= -1.0 || wert >= 1.0
  then 0.0
  else sqrt (1.0 -. wert*.wert)

let verbind gric =
  let gricf = float_of_int gric  in
  let rand = 1.0/.3.0  in
  let corand = 1.0-.rand  in
  let stuetzpunkte = Array.init verbind_stuetzen (fun i ->
    Random.float 1.0, Random.float 1.0, Random.float 1.0)  in
  let breite = gric*4  in
  let hoehe = gric*4*(verbind_bilder+1)  in
  let pixel = Array.init hoehe (fun y -> Array.make breite durchsichtig)  in
  for i=0 to verbind_bilder do
    let winkel = (float_of_int i)/.(float_of_int verbind_bilder) *. 2.0*.pi  in
    let haus,vaus = if i=0
    then (0.0,0.0)
    else (sin winkel, cos winkel)  in
    for j=0 to 3 do
      let unten = j>0 && j<3  in
      let oben = j>1  in
      for k=0 to 3 do
        let rechts = k>0 && k<3  in
        let links = k>1  in
        Array.iter
          (fun (x,y,z) ->
            let h_x = huegel rand corand x  in
            let h_y = huegel rand corand y  in
            let h_mitte = huegel (rand-.0.5) (corand-.0.5)
              (sqrt ((x-.0.5)*.(x-.0.5)+.(y-.0.5)*.(y-.0.5)))  in
            let hoehe = max (max
              h_mitte
              (if if x<=0.5 then links else rechts  then h_y  else 0.0))
              (if if y<=0.5 then oben else unten  then h_x  else 0.0)  in
            if z<hoehe && (links || rechts || oben || unten)
            then (
              let dx = misch4 rand corand 0.0
                (misch3 rand corand
                  (if links  then rand  else 0.0)
                  (if rechts  then rand  else 0.0)
                  x)
                y  in
              let dy = misch4 rand corand 0.0
                (misch3 rand corand
                  (if oben  then rand  else 0.0)
                  (if unten  then rand  else 0.0)
                  y)
                x  in
              let x,y = x+.haus*.dx, y+.vaus*.dy  in
              let x,y =
                gric*k + int_of_float (floor (x*.gricf)),
                gric*(j+4*i) + int_of_float (floor (y*.gricf))  in
              pixel.(y).(x) <- hintergrund))
          stuetzpunkte
      done
    done
  done;
  (breite,hoehe,pixel)

;;

let gric,command,outname = Gen_common.parse_args ()  in

Random.init 321;
  (* Wenn das Programm mal mehr als ein Bild auf einmal ausgeben kann,
     dann muß diese Initialisierung vor jedes zufällige Bild einzeln. *)

let bild = match command with
| "mscLeer" -> leer
| "mscHinter" -> hinter
| "mscVerbind" -> verbind
  in

gib_xpm_aus (rgb_grau 0.0) outname (bild gric)

