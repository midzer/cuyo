(*
   Copyright 2006,2010,2011 by Mark Weyer
   Maintenance modifications 2008,2011 by the cuyo developers

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
open Helfer

module Rgb = Vektor.Vektor(Natmod.Drei)
module Rgba = Vektor.Vektor(Natmod.Vier)

type punkt = float * float

type bildchen = int * int * (punkt -> farbe)

let monochrom farbe breite hoehe = breite, hoehe, function p -> farbe

let spiegel_x (breite,hoehe,farben) =
  let breite_f = float_of_int breite  in
  breite, hoehe,
  function x,y -> farben (breite_f-.x,y)

let kombiniere_bildchen breite hoehe einzelne =
  breite, hoehe,
  function (x,y) -> List.fold_left
    (function farbe -> function (x0,y0,(breite,hoehe,farben)) ->
      if (float_of_int x0)<=x && (x<=(float_of_int (x0+breite)))
          && (float_of_int y0)<=y && (y<=(float_of_int (y0+hoehe)))
        then farben (x-.(float_of_int x0), y-.(float_of_int y0))
        else farbe)
    durchsichtig
    einzelne

let ueberlagerung (b,h,funten) (b',h',foben) maske =
  match maske  with
  | None -> (b,h, fun p ->
    let o = foben p  in
    let d = nur_durchsichtig o  in
    if d=0.0  then o  else misch2 o (funten p) d)
  | Some (b'',h'',fmaske) -> (b,h, fun p ->
    let d = nur_durchsichtig (fmaske p)  in
    if d=0.0
    then foben p
    else if d=1.0
        then funten p
	else misch2 (foben p) (funten p) d)




type pixelbild = int * int * farbe array array

let berechne aufloesung (breite,hoehe,farben) =
  let breite,hoehe = breite*aufloesung,hoehe*aufloesung  in
  let aufloesung = 1.0/.(float_of_int aufloesung)  in
  breite,hoehe,Array.init hoehe (function y ->
    let yf = ((float_of_int (hoehe-y))-.0.5)*.aufloesung  in
    Array.init breite (function x ->
      farben (((float_of_int x)+.0.5)*.aufloesung, yf)))

let abstrahiere aufloesung (breite,hoehe,pixel) =
  breite/aufloesung, hoehe/aufloesung,
  let auff = float_of_int aufloesung  in
  let limitx,limity = breite-1, hoehe-1   in
  let runde limit f = min limit (int_of_float (floor (f*.auff)))  in
  (fun (x,y) -> pixel.(limity-runde limity y).(runde limitx x))


let ausschnitt x0 y0 x1 y1 (b,h,f) =
  (x1-x0,y1-y0,
    Array.init (y1-y0) (fun y -> Array.init (x1-x0) (fun x ->
      f.(y+y0).(x+x0))))

let kleb hori (b1,h1,f1) (b2,h2,f2) = if hori
  then (b1+b2, h1,
    Array.init h1 (fun y -> Array.init (b1+b2) (fun x -> if x<b1
      then f1.(y).(x)
      else f2.(y).(x-b1))))
  else (b1, h1+h2,
    Array.init (h1+h2) (fun y -> Array.init b1 (fun x -> if y<h1
      then f1.(y).(x)
      else f2.(y-h1).(x))))


let list_n n =
  let rec doit i = if i=n  then []  else i::(doit (i+1))  in
  doit 0

let durchschnitt n (w,h,pixel) = (w/n, h/n,
  let liste = list_n n  in
  Array.init (h/n) (fun y -> Array.init (w/n) (fun x ->
    misch (List.concat (List.map
      (fun i -> List.map
        (fun j -> 1.0, pixel.(y*n+i).(x*n+j))
        liste)
      liste)))))

let extrahiere_farben (breite,hoehe,pixel) =
  let n,k = Array.fold_left (Array.fold_left (fun (n,k) -> fun farbe ->
      if FarbMap.mem farbe k
      then n,k
      else n+1, FarbMap.add farbe n k))
    (0,FarbMap.empty)
    pixel  in
  let p = Array.make n schwarz  in    (* schwarz ist ein dummy *)
  FarbMap.iter
    (fun farbe -> fun i -> p.(i)<-farbe)
    k;
  p,k

let extrahiere_verteilung (breite,hoehe,pixel) =
  let n,v = Array.fold_left (Array.fold_left
    (fun (n,v) -> fun farbe -> if FarbMap.mem farbe v
      then n, FarbMap.add farbe ((FarbMap.find farbe v)+1) v
      else n+1, FarbMap.add farbe 1 v))
    (0,FarbMap.empty)  pixel  in
  let v' = Array.make n (schwarz,0)  in
  ignore (FarbMap.fold
    (fun farbe -> fun anzahl -> fun n ->
      v'.(n) <- (farbe,anzahl);
      n+1)
    v  0);
  v'


type farbreduktions_methode =
| Heuristik_mittlerer_euklidischer
| Heuristik_maximaler_euklidischer

let reduziere_farben methode mussrein anzahl bild = match methode with
  | Heuristik_mittlerer_euklidischer ->
    reduziere_farben1 mussrein (extrahiere_verteilung bild) anzahl
  | Heuristik_maximaler_euklidischer ->
    reduziere_farben2 mussrein (fst (extrahiere_farben bild)) anzahl



let xpm_zeichen = " #@*+-=~/.,:;_&%$!?|" ^
  "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" ^
  "'`^(){}[]<>"

let anz_xpm_zeichen = String.length xpm_zeichen


let gib_xpm_aus h palette farbsuche dateiname (breite,hoehe,pixel) =
  let anz_farb = Array.length palette  in
  let kodier_breite =
    let rec log n = if n>anz_xpm_zeichen
      then 1+(log (n/anz_xpm_zeichen))
      else 1  in
    log anz_farb  in
  let kodiere i =
    let rec kodiere_rest rest_laenge rest_i =
      if rest_laenge=0
        then ""
        else (kodiere_rest (rest_laenge-1) (rest_i/anz_xpm_zeichen))
          ^(String.sub xpm_zeichen (rest_i mod anz_xpm_zeichen) 1)  in
    kodiere_rest kodier_breite i  in

  let datei = open_out dateiname  in
  let os = output_string datei  in
  let oi i = os (string_of_int i)  in

  let hex n =
    let hex_ziffer n = String.sub "0123456789ABCDEF" n 1  in
    (hex_ziffer (n/16))^(hex_ziffer (n mod 16))  in
  let hex f = os (hex (truncate (255.0*.f+.0.5)))  in

  os "/* XPM */\n";
  os "static char * noname[] = {\n";
  os "\""; oi breite; os " "; oi hoehe; os " ";
    oi anz_farb; os " "; oi kodier_breite; os "\"";
  ignore (Array.fold_left
    (function i -> function f ->
      os ",\n\""; os (kodiere i); os " c ";
      (if f=durchsichtig
        then os "None"
        else if f=hintergrund
          then os "Background"
          else
            let rgb = zu_rgb h h f  in
            os "#"; hex (Rgb.koord rgb 0);
	    hex (Rgb.koord rgb 1); hex (Rgb.koord rgb 2));
      os "\"";
      i+1)
    0
    palette);
  for y = 0 to hoehe-1 do
    os ",\n\"";
    for x = 0 to breite-1 do
      os (kodiere (farbsuche pixel.(y).(x)))
    done;
    os "\"";
  done;
  os "};\n";
  close_out datei


let gib_xpm_aus_exakt h name bild =
  let palette,karte = extrahiere_farben bild  in
  gib_xpm_aus h palette (fun farbe -> FarbMap.find farbe karte) name bild

let gib_xpm_aus_palette h palette =
  let index = mach_index palette  in
  gib_xpm_aus h palette (naechste_farbe palette index)

let gib_xpm_aus_anzahl ?(methode=Heuristik_maximaler_euklidischer)
    h anzahl name bild =
  gib_xpm_aus_palette h (reduziere_farben methode [| |] anzahl bild) name bild

let gib_xpm_aus ?methode h = gib_xpm_aus_anzahl ?methode h anz_xpm_zeichen


let gib_ppm_aus name (breite,hoehe,pixel) =
  let schw = rgb_grau 0.0  in
  let datei = open_out name  in
  let os = output_string datei  in
  let oi i = os (string_of_int i)  in
  let ob = output_byte datei  in
  os "P6\n";
  oi breite; os " ";
  oi hoehe; os "\n";
  os "255\n";
  Array.iter (Array.iter (fun farbe ->
      let rgb = zu_rgb schw schw farbe  in
      for i=0 to 2 do
        ob (int_of_float (floor
          ((max 0.0 (min 1.0 (Rgb.koord rgb i)))*.255.0 +. 0.5)))
      done))
    pixel;
  close_out datei



exception Falscher_TupleType

let lies_xpm dateiname =
  let lex = Lexing.from_channel (open_in dateiname)  in
  let lies_zeile u = Xpmlex.xpm lex  in
  let zeile1 = Lexing.from_string (lies_zeile ())  in
  let zahl u = Xpmlex.erstezeile zeile1  in
  let breite = zahl ()  in
  let hoehe = zahl ()  in
  let anz_farben = zahl ()  in
  let charpp = zahl ()  in
  let farben = Array.to_list (Array.init anz_farben (function i ->
    let zeile = lies_zeile ()  in
    prefix zeile charpp,
    Xpmlex.farbzeilenrest (Lexing.from_string
      (coprefix zeile charpp))))  in
  breite,hoehe,Array.init hoehe (function y ->
    let zeile = lies_zeile ()  in
    Array.init breite (function x ->
      List.assoc (String.sub zeile (x*charpp) charpp) farben))

let lies_ppm dateiname =
  let (breite,hoehe,tiefe,maxval,daten),typ =
    Pam.read_pam (open_in dateiname)  in
  let maxvalf = float_of_int maxval  in
  if tiefe!=3
    then raise Falscher_TupleType
    else
      breite,hoehe,
      Array.map
        (Array.map (function d ->
          von_rgb (Rgb.aus_array (Array.map
            (fun i -> (float_of_int i)/.maxvalf) d))))
        daten

let lies_pam dateiname =
  let (breite,hoehe,tiefe,maxval,daten),typ =
    Pam.read_pam (open_in dateiname)  in
  let maxvalf = float_of_int maxval  in
  if tiefe!=4
    then raise Falscher_TupleType
    else
      breite,hoehe,
      Array.map
        (Array.map (function d ->
          von_rgba (Rgba.aus_array (Array.map
            (fun i -> (float_of_int i)/.maxvalf) d))))
        daten


